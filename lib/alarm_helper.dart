import 'package:norway_roznama_new_project/core/audio/adhan_service.dart';
import 'package:norway_roznama_new_project/core/util/adhan_sound_mapper.dart';

/// Helper class for scheduling prayer alarms.
/// Uses native Android AlarmManager via AdhanService for reliable
/// alarm triggering even when the app is terminated.
class AlarmHelper {
  /// Schedule a prayer alarm at the specified time.
  ///
  /// [id] - Unique alarm ID (used for cancellation)
  /// [prayerName] - Name of the prayer (e.g., "Fajr", "Dhuhr")
  /// [prayerTime] - DateTime when the alarm should fire
  /// [customSoundPath] - Optional custom adhan sound path (from assets)
  ///                     If not provided, defaults to Alafasi (backend ID 1)
  static Future<void> setPrayerAlarm({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    String? customSoundPath,
  }) async {
    // Use custom sound path or default to Alafasi (backend ID 1)
    String soundPath = customSoundPath ??
        AdhanSoundMapper.getAssetPath(1) ??
        'sounds/alafasi.mp3';

    // Remove 'assets/' prefix if present - AdhanService handles this
    if (soundPath.startsWith('assets/')) {
      soundPath = soundPath.substring(7);
    }

    print(
        '📿 [AlarmHelper] Scheduling $prayerName alarm at $prayerTime with sound: $soundPath');

    await AdhanService.schedule(
      alarmId: id,
      scheduledTime: prayerTime,
      soundPath: soundPath,
      title: 'وقت صلاة $prayerName',
      body: 'حان الآن وقت صلاة $prayerName',
    );
  }

  /// Cancel a scheduled prayer alarm.
  ///
  /// [id] - ID of the alarm to cancel
  static Future<void> cancelPrayerAlarm(int id) async {
    print('🗑️ [AlarmHelper] Cancelling alarm with ID: $id');
    await AdhanService.cancel(id);
  }
}
