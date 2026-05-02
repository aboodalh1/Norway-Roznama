import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:norway_roznama_new_project/core/audio/adhan_audio_handler.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/prayer_reminder_config.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/reminder_instance.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/reminder_config_repository.dart';

/// Dedicated notification channel for sub-reminders.
/// Separate from the main adhan foreground service channel.
const String kReminderChannelId = 'prayer_reminder_channel';
const String kReminderChannelName = 'Prayer Reminders';

/// Executes a reminder task inside [callbackDispatcher].
///
/// Returns true on success (WorkManager marks work as SUCCESS),
/// false on unrecoverable failure (WorkManager will not retry by default;
/// WorkManager retries are only triggered by returning a Result.retry, but
/// the workmanager Dart plugin maps false → FAILURE without auto-retry,
/// which is the correct behavior here: if the invariant is violated we do
/// not want WorkManager to keep retrying).
Future<bool> handleReminderTask(Map<String, dynamic>? inputData) async {
  if (inputData == null) {
    print('[ReminderWorker] No inputData — skipping.');
    return true;
  }

  try {
    // Parse inputs.
    final int prayerIndex = inputData['prayerIndex'] as int? ?? -1;
    final String prayerName = inputData['prayerName'] as String? ?? '';
    final String reminderTypeStr = inputData['reminderType'] as String? ?? '';
    final String modeStr = inputData['mode'] as String? ?? '';
    final int offsetMinutes = inputData['offsetMinutes'] as int? ?? 0;
    final int adhanEpochMillis = inputData['adhanEpochMillis'] as int? ?? 0;
    final int triggerEpochMillis = inputData['triggerEpochMillis'] as int? ?? 0;
    final String instanceId = inputData['instanceId'] as String? ?? '';
    final int notificationId = inputData['notificationId'] as int? ?? 0;
    final String soundPath = inputData['soundPath'] as String? ?? '';

    if (prayerIndex < 0 || instanceId.isEmpty) {
      print('[ReminderWorker] Invalid inputData fields — skipping.');
      return true;
    }

    final ReminderType type = ReminderType.values.firstWhere(
      (e) => e.name == reminderTypeStr,
      orElse: () => ReminderType.before,
    );
    final ReminderMode mode = ReminderMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => ReminderMode.frequent,
    );

    print(
        '[ReminderWorker] Task: prayer=$prayerIndex type=${type.name} mode=${mode.name} instanceId=$instanceId');

    // --- Defense-in-depth: re-validate timing invariants at execution time ---
    if (type == ReminderType.before && triggerEpochMillis >= adhanEpochMillis) {
      print(
          '[ReminderWorker] Invariant violated: before trigger >= adhan. Aborting. instanceId=$instanceId');
      _consumeIfOnce(instanceId, mode, ConsumeReason.expiredStale);
      return true;
    }
    if (type == ReminderType.after && triggerEpochMillis <= adhanEpochMillis) {
      print(
          '[ReminderWorker] Invariant violated: after trigger <= adhan. Aborting. instanceId=$instanceId');
      _consumeIfOnce(instanceId, mode, ConsumeReason.expiredStale);
      return true;
    }

    // --- Once-mode: check consumed flag ---
    if (mode == ReminderMode.once) {
      await CacheHelper.init();
      if (ReminderConfigRepository.isConsumed(instanceId)) {
        print('[ReminderWorker] Once instance already consumed: $instanceId');
        return true;
      }
    }

    // --- Mute check (respect global mute the same way iqama does) ---
    if (CacheHelper.getData(key: 'is_muted') == true) {
      print('[ReminderWorker] App is muted. Skipping reminder.');
      _consumeIfOnce(instanceId, mode, ConsumeReason.expiredStale);
      return true;
    }

    // --- Show the notification ---
    final bool shown = await _showReminderNotification(
      notificationId: notificationId,
      prayerName: prayerName,
      type: type,
      offsetMinutes: offsetMinutes,
    );

    if (!shown) {
      print('[ReminderWorker] Notification emission failed for $instanceId');
      return false; // Let WorkManager mark as FAILURE (no auto-retry)
    }

    print('[ReminderWorker] Notification shown for $instanceId');

    // --- Play adhan audio ---
    if (soundPath.isNotEmpty) {
      try {
        final String title = type == ReminderType.before
            ? 'تذكير قبل $offsetMinutes دقيقة'
            : 'تذكير بعد $offsetMinutes دقيقة';
        final String body = type == ReminderType.before
            ? 'بعد $offsetMinutes دقيقة موعد $prayerName'
            : 'مضى $offsetMinutes دقيقة على $prayerName';
        await initAdhanAudioHandler();
        await AdhanAudioController.playAdhan(
          soundPath: soundPath,
          id: notificationId,
          title: title,
          body: body,
        );
        print('[ReminderWorker] Adhan audio started for $instanceId');
      } catch (e) {
        print('[ReminderWorker] Adhan audio error (non-fatal): $e');
      }
    }

    // --- Mark once-instance consumed ---
    _consumeIfOnce(instanceId, mode, ConsumeReason.fired);

    return true;
  } catch (e, st) {
    print('[ReminderWorker] Unexpected error: $e\n$st');
    return false;
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

Future<bool> _showReminderNotification({
  required int notificationId,
  required String prayerName,
  required ReminderType type,
  required int offsetMinutes,
}) async {
  try {
    final plugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: android);
    await plugin.initialize(settings);

    // Ensure the reminder channel exists in this isolate's process context.
    // Android 8+ silently drops notifications sent to a channel that has not
    // been created in the current process — this call is idempotent.
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            kReminderChannelId,
            kReminderChannelName,
            importance: Importance.high,
          ),
        );

    final String title = type == ReminderType.before
        ? 'تذكير قبل $offsetMinutes دقيقة'
        : 'تذكير بعد $offsetMinutes دقيقة';
    final String body = type == ReminderType.before
        ? 'بعد $offsetMinutes دقيقة موعد $prayerName'
        : 'مضى $offsetMinutes دقيقة على $prayerName';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      kReminderChannelId,
      kReminderChannelName,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: 'reminder',
    );
    return true;
  } catch (e) {
    print('[ReminderWorker] _showReminderNotification error: $e');
    return false;
  }
}

void _consumeIfOnce(
    String instanceId, ReminderMode mode, ConsumeReason reason) {
  if (mode == ReminderMode.once) {
    try {
      ReminderConfigRepository.markConsumed(instanceId, reason);
    } catch (e) {
      print('[ReminderWorker] Failed to mark consumed: $e');
    }
  }
}
