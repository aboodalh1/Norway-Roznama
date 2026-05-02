import 'package:workmanager/workmanager.dart';

import '../../features/prays_and_times/prays_settings/data/model/prayer_reminder_config.dart';
import '../../features/prays_and_times/prays_settings/data/model/reminder_instance.dart';
import '../../features/prays_and_times/prays_settings/data/repo/reminder_config_repository.dart';

/// WorkManager task name used for all reminder tasks.
const String kReminderTaskName = 'reminderTask';

/// Notification ID base for before-reminders: 6000 + prayerIndex*2
/// Notification ID base for after-reminders:  6001 + prayerIndex*2
/// Range: 6000–6013 (7 prayers × 2 slots) — safe from existing IDs.
int reminderNotificationId(int prayerIndex, ReminderType type) =>
    6000 + prayerIndex * 2 + (type == ReminderType.before ? 0 : 1);

/// Orchestrates scheduling and cancellation of sub-reminder WorkManager tasks.
///
/// Invariants enforced here (and re-checked inside the worker):
///   before  → triggerTime < adhanTime
///   after   → triggerTime > adhanTime
///
/// [ExistingWorkPolicy.replace] is used for frequent slots so that calling
/// reschedule always refreshes the trigger with the latest prayer time.
/// [ExistingWorkPolicy.keep] is used for once slots — the first scheduling
/// wins; to force replacement (e.g. offset changed) call [cancelPrayerSlot]
/// before re-enqueuing.
class ReminderScheduler {
  const ReminderScheduler._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Re-schedules all enabled reminder slots for every prayer in [prayerTimes].
  ///
  /// [prayerTimes] — list of 7 [DateTime] values (today's or next-occurrence).
  /// [configs]     — parallel list of 7 [PrayerReminderConfig].
  /// [prayerNames] — Arabic prayer names (for notification body).
  /// [soundPaths]  — parallel list of 7 asset paths for adhan audio playback.
  ///                 Pass an empty string to skip audio for that prayer.
  ///
  /// Each slot's own [ReminderSlotConfig.enabled] flag is the sole gate for
  /// scheduling. Reminders are independent of the main adhan on/off switch.
  static Future<void> rescheduleAllReminders({
    required List<DateTime> prayerTimes,
    required List<PrayerReminderConfig> configs,
    required List<String> prayerNames,
    required List<String> soundPaths,
  }) async {
    assert(prayerTimes.length == 7);
    assert(configs.length == 7);
    assert(prayerNames.length == 7);
    assert(soundPaths.length == 7);

    print('[ReminderScheduler] rescheduleAllReminders start');

    for (int i = 0; i < 7; i++) {
      await reschedulePrayerReminders(
        prayerIndex: i,
        prayerTime: prayerTimes[i],
        config: configs[i],
        prayerName: prayerNames[i],
        soundPath: soundPaths[i],
      );
    }

    print('[ReminderScheduler] rescheduleAllReminders complete');
  }

  /// Re-schedules reminder slots for a single prayer.
  static Future<void> reschedulePrayerReminders({
    required int prayerIndex,
    required DateTime prayerTime,
    required PrayerReminderConfig config,
    required String prayerName,
    String soundPath = '',
  }) async {
    await _handleSlot(
      prayerIndex: prayerIndex,
      prayerTime: prayerTime,
      slot: config.before,
      type: ReminderType.before,
      prayerName: prayerName,
      soundPath: soundPath,
    );
    await _handleSlot(
      prayerIndex: prayerIndex,
      prayerTime: prayerTime,
      slot: config.after,
      type: ReminderType.after,
      prayerName: prayerName,
      soundPath: soundPath,
    );
  }

  /// Cancels all reminder WorkManager tasks for every prayer.
  static Future<void> cancelAllReminders() async {
    for (int i = 0; i < 7; i++) {
      await cancelPrayerReminders(i);
    }
  }

  /// Cancels both (before + after) reminder tasks for [prayerIndex].
  static Future<void> cancelPrayerReminders(int prayerIndex) async {
    await cancelPrayerSlot(prayerIndex, ReminderType.before);
    await cancelPrayerSlot(prayerIndex, ReminderType.after);
  }

  /// Cancels a single slot's WorkManager task for [prayerIndex].
  /// Handles both frequent (by stable name) and any pending once instances.
  static Future<void> cancelPrayerSlot(
      int prayerIndex, ReminderType type) async {
    // Cancel the stable frequent slot name.
    final freqName = _freqWorkName(prayerIndex, type);
    await Workmanager().cancelByUniqueName(freqName);

    // Cancel any pending once instances for this slot.
    final instances = ReminderConfigRepository.loadAllOnceInstances()
        .where((e) =>
            e.prayerIndex == prayerIndex &&
            e.type == type &&
            !e.consumed)
        .toList();
    for (final inst in instances) {
      await Workmanager().cancelByUniqueName(inst.workManagerName);
      ReminderConfigRepository.markConsumed(
          inst.id, ConsumeReason.slotDisabled);
    }

    print(
        '[ReminderScheduler] Cancelled slot prayer=$prayerIndex type=${type.name}');
  }

  // ---------------------------------------------------------------------------
  // Reconcile on startup
  // ---------------------------------------------------------------------------

  /// Called once on app cold start. Re-validates all scheduled reminders
  /// against the current configs and prayer times.
  ///
  /// Stale once-instances (trigger already passed) are marked consumed.
  /// Frequent slots are always replaced with fresh trigger times.
  static Future<void> reconcileOnAppStart({
    required List<DateTime> prayerTimes,
    required List<PrayerReminderConfig> configs,
    required List<String> prayerNames,
    required List<String> soundPaths,
  }) async {
    print('[ReminderScheduler] reconcileOnAppStart start');

    // Prune old consumed once-instances.
    ReminderConfigRepository.pruneConsumedInstances();

    // Re-schedule everything. Frequent slots use REPLACE so they always refresh.
    await rescheduleAllReminders(
      prayerTimes: prayerTimes,
      configs: configs,
      prayerNames: prayerNames,
      soundPaths: soundPaths,
    );

    print('[ReminderScheduler] reconcileOnAppStart complete');
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static Future<void> _handleSlot({
    required int prayerIndex,
    required DateTime prayerTime,
    required ReminderSlotConfig slot,
    required ReminderType type,
    required String prayerName,
    String soundPath = '',
  }) async {
    if (!slot.enabled) {
      await cancelPrayerSlot(prayerIndex, type);
      return;
    }

    final now = DateTime.now();

    // Compute trigger time.
    final DateTime triggerTime = type == ReminderType.before
        ? prayerTime.subtract(Duration(minutes: slot.offsetMinutes))
        : prayerTime.add(Duration(minutes: slot.offsetMinutes));

    // --- Invariant checks ---
    if (type == ReminderType.before && !triggerTime.isBefore(prayerTime)) {
      print(
          '[ReminderScheduler] Invariant violated: before trigger >= adhan. Skipping prayer=$prayerIndex');
      return;
    }
    if (type == ReminderType.after && !triggerTime.isAfter(prayerTime)) {
      print(
          '[ReminderScheduler] Invariant violated: after trigger <= adhan. Skipping prayer=$prayerIndex');
      return;
    }

    // If trigger is in the past for a once-only reminder, advance to next day.
    DateTime effectiveTrigger = triggerTime;
    DateTime effectivePrayer = prayerTime;
    if (triggerTime.isBefore(now)) {
      effectivePrayer = prayerTime.add(const Duration(days: 1));
      effectiveTrigger = type == ReminderType.before
          ? effectivePrayer.subtract(Duration(minutes: slot.offsetMinutes))
          : effectivePrayer.add(Duration(minutes: slot.offsetMinutes));
    }

    final Duration initialDelay = effectiveTrigger.difference(now);

    if (slot.mode == ReminderMode.frequent) {
      await _enqueueFrequent(
        prayerIndex: prayerIndex,
        prayerName: prayerName,
        type: type,
        slot: slot,
        adhanEpochMillis: effectivePrayer.millisecondsSinceEpoch,
        triggerEpochMillis: effectiveTrigger.millisecondsSinceEpoch,
        initialDelay: initialDelay,
        soundPath: soundPath,
      );
    } else {
      await _enqueueOnce(
        prayerIndex: prayerIndex,
        prayerName: prayerName,
        type: type,
        slot: slot,
        adhanEpochMillis: effectivePrayer.millisecondsSinceEpoch,
        triggerEpochMillis: effectiveTrigger.millisecondsSinceEpoch,
        initialDelay: initialDelay,
        soundPath: soundPath,
      );
    }
  }

  static Future<void> _enqueueFrequent({
    required int prayerIndex,
    required String prayerName,
    required ReminderType type,
    required ReminderSlotConfig slot,
    required int adhanEpochMillis,
    required int triggerEpochMillis,
    required Duration initialDelay,
    String soundPath = '',
  }) async {
    final uniqueName = _freqWorkName(prayerIndex, type);
    final instanceId = ReminderInstance.frequentId(prayerIndex, type);
    final notifId = reminderNotificationId(prayerIndex, type);

    await Workmanager().registerOneOffTask(
      uniqueName,
      kReminderTaskName,
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: _buildInputData(
        prayerIndex: prayerIndex,
        prayerName: prayerName,
        type: type,
        mode: slot.mode,
        offsetMinutes: slot.offsetMinutes,
        adhanEpochMillis: adhanEpochMillis,
        triggerEpochMillis: triggerEpochMillis,
        instanceId: instanceId,
        notificationId: notifId,
        soundPath: soundPath,
      ),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
    );

    print(
        '[ReminderScheduler] Enqueued frequent reminder: $uniqueName delay=${initialDelay.inMinutes}m');
  }

  static Future<void> _enqueueOnce({
    required int prayerIndex,
    required String prayerName,
    required ReminderType type,
    required ReminderSlotConfig slot,
    required int adhanEpochMillis,
    required int triggerEpochMillis,
    required Duration initialDelay,
    String soundPath = '',
  }) async {
    final instanceId =
        ReminderInstance.onceId(prayerIndex, type, adhanEpochMillis);

    // Skip if already consumed.
    if (ReminderConfigRepository.isConsumed(instanceId)) {
      print(
          '[ReminderScheduler] Once instance $instanceId already consumed; skipping.');
      return;
    }

    final uniqueName = 'reminder_once_${prayerIndex}_${type.name}_$adhanEpochMillis';
    final notifId = reminderNotificationId(prayerIndex, type);

    // Persist the instance before enqueuing so the worker can validate it.
    final instance = ReminderInstance(
      id: instanceId,
      prayerIndex: prayerIndex,
      type: type,
      mode: ReminderMode.once,
      adhanEpochMillis: adhanEpochMillis,
      triggerEpochMillis: triggerEpochMillis,
      offsetMinutes: slot.offsetMinutes,
      consumed: false,
      createdAt: DateTime.now(),
    );
    ReminderConfigRepository.upsertOnceInstance(instance);

    await Workmanager().registerOneOffTask(
      uniqueName,
      kReminderTaskName,
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      inputData: _buildInputData(
        prayerIndex: prayerIndex,
        prayerName: prayerName,
        type: type,
        mode: slot.mode,
        offsetMinutes: slot.offsetMinutes,
        adhanEpochMillis: adhanEpochMillis,
        triggerEpochMillis: triggerEpochMillis,
        instanceId: instanceId,
        notificationId: notifId,
        soundPath: soundPath,
      ),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
    );

    print(
        '[ReminderScheduler] Enqueued once reminder: $uniqueName delay=${initialDelay.inMinutes}m');
  }

  static String _freqWorkName(int prayerIndex, ReminderType type) =>
      'reminder_freq_${prayerIndex}_${type.name}';

  static Map<String, dynamic> _buildInputData({
    required int prayerIndex,
    required String prayerName,
    required ReminderType type,
    required ReminderMode mode,
    required int offsetMinutes,
    required int adhanEpochMillis,
    required int triggerEpochMillis,
    required String instanceId,
    required int notificationId,
    String soundPath = '',
  }) {
    return {
      'prayerIndex': prayerIndex,
      'prayerName': prayerName,
      'reminderType': type.name,
      'mode': mode.name,
      'offsetMinutes': offsetMinutes,
      'adhanEpochMillis': adhanEpochMillis,
      'triggerEpochMillis': triggerEpochMillis,
      'instanceId': instanceId,
      'notificationId': notificationId,
      'soundPath': soundPath,
    };
  }
}
