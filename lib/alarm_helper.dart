
import 'package:norway_roznama_new_project/alarm_service.dart';

class AlarmHelper {
  static Future<void> setPrayerAlarm({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    String? customSoundPath,
  }) async {
    final soundPath = customSoundPath ?? 'assets/sounds/alafasi.mp3';

    await AlarmService.scheduleAlarm(
      id: id,
      hour: prayerTime.hour,
      minutes: prayerTime.minute,
      title: '$prayerName Prayer Time',
      body: 'It\'s time for $prayerName prayer',
      soundPath: soundPath,
    );
  }
}