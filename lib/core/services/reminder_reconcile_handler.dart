import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:norway_roznama_new_project/core/services/reminder_scheduler.dart';
import 'package:norway_roznama_new_project/core/util/adhan_sound_mapper.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/reminder_config_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz_lib;

/// WorkManager task name for the background reconcile pass.
const String kReminderReconcileTaskName = 'reminderReconcileTask';

/// Task name used when re-enqueuing after system events from the Kotlin receiver.
const String kReminderReconcileUniqueName = 'reminder_reconcile_system_event';

/// Prayer names in the same fixed order used by [PraysCubit.praysName].
const List<String> _kPrayerNames = [
  'الفجر',
  'الشروق',
  'الظهر',
  ' العصر الأول',
  'العصر الثاني',
  'المغرب',
  'العشاء',
];

/// Executed inside [callbackDispatcher] when [taskName] == [kReminderReconcileTaskName].
///
/// Reads persisted prayer times and reminder configs from SharedPreferences,
/// then reschedules all enabled reminder WorkManager tasks.
/// This handles: reboot (WorkManager auto-restores this task), timezone change,
/// manual time change, and app update scenarios.
Future<bool> handleReminderReconcileTask() async {
  try {
    print('[ReminderReconcile] Starting reconciliation pass.');

    await CacheHelper.init();

    // Load cached prayer times (List<String> of 12h strings).
    final dynamic rawTimes = CacheHelper.getData(key: 'praysTimes');
    if (rawTimes == null) {
      print('[ReminderReconcile] No cached prayer times; skipping.');
      return true;
    }
    final List<String> times12h = List<String>.from(rawTimes as List);
    if (times12h.length < 7) {
      print('[ReminderReconcile] Insufficient prayer times; skipping.');
      return true;
    }

    // Initialize timezone.
    tz.initializeTimeZones();
    String tzName;
    try {
      tzName = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      tzName = 'UTC';
    }
    tz_lib.setLocalLocation(tz_lib.getLocation(tzName));

    final now = DateTime.now();

    // Parse 12h strings → next-occurrence DateTime.
    final List<DateTime> prayerTimes = [];
    for (final t in times12h) {
      try {
        final parsed = _parse12hTime(t, now);
        DateTime candidate = DateTime(
            now.year, now.month, now.day, parsed.hour, parsed.minute);
        if (candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
        prayerTimes.add(candidate);
      } catch (e) {
        print('[ReminderReconcile] Error parsing time "$t": $e');
        prayerTimes.add(now.add(const Duration(hours: 1)));
      }
    }

    // Load configs.
    ReminderConfigRepository.runMigrationIfNeeded();
    final configs = ReminderConfigRepository.loadAllConfigs();

    // Build sound paths per prayer from cached reader IDs.
    final List<String> soundPaths = List.generate(7, (i) {
      final int readerId =
          CacheHelper.getData(key: 'pray_reader$i') as int? ?? 1;
      return AdhanSoundMapper.getAssetPath(readerId) ??
          AdhanSoundMapper.getAssetPath(1) ??
          '';
    });

    // Prune stale once instances.
    ReminderConfigRepository.pruneConsumedInstances();

    // Reschedule. Each slot's own enabled flag determines whether it fires.
    await ReminderScheduler.rescheduleAllReminders(
      prayerTimes: prayerTimes,
      configs: configs,
      prayerNames: _kPrayerNames,
      soundPaths: soundPaths,
    );

    print('[ReminderReconcile] Reconciliation complete.');
    return true;
  } catch (e, st) {
    print('[ReminderReconcile] Error: $e\n$st');
    return false;
  }
}

/// Minimal 12h time parser (handles "hh:mm AM/PM" format from cache).
DateTime _parse12hTime(String raw, DateTime base) {
  // Normalize: remove leading/trailing spaces and non-breaking spaces.
  final s = raw.trim().replaceAll('\u00a0', ' ');

  // Try to detect AM/PM.
  final isPm = s.toUpperCase().contains('PM');
  final isAm = s.toUpperCase().contains('AM');

  // Extract HH:MM portion.
  final colonIdx = s.indexOf(':');
  if (colonIdx < 0) throw FormatException('No colon: $s');

  int hour = int.parse(s.substring(0, colonIdx).trim());
  final rest = s.substring(colonIdx + 1);
  int minute = int.parse(rest.replaceAll(RegExp(r'[^\d]'), '').substring(0, 2));

  if (isPm && hour != 12) hour += 12;
  if (isAm && hour == 12) hour = 0;

  return DateTime(base.year, base.month, base.day, hour, minute);
}
