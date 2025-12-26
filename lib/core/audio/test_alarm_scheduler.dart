import 'package:norway_roznama_new_project/core/audio/adhan_service.dart';

/// Unique ID for the test alarm
const int testAlarmId = 9999;

/// Schedule a test alarm to fire after the specified delay.
/// 
/// Uses native Android AlarmManager scheduling, which works even when 
/// the app is completely terminated. No Flutter callback is needed because
/// the native AdhanAlarmReceiver directly starts the AdhanForegroundService.
Future<bool> scheduleTestAlarm({
  Duration delay = const Duration(seconds: 15),
  String soundPath = 'sounds/alafasi.mp3',
  String title = 'Test Adhan',
  String body = 'Background alarm triggered! Tap Stop to end.',
}) async {
  print('📅 [TestAlarm] Scheduling alarm for ${delay.inSeconds} seconds from now...');
  
  // Cancel any existing alarm first
  await cancelTestAlarm();
  
  final scheduledTime = DateTime.now().add(delay);
  TestAlarmState.setScheduledTime(scheduledTime);
  print('📅 [TestAlarm] Scheduled time: $scheduledTime');
  
  // Use native Android alarm scheduling via AdhanService
  // This works even when app is terminated because:
  // 1. Native AlarmManager schedules a PendingIntent
  // 2. When alarm fires, AdhanAlarmReceiver receives it (native BroadcastReceiver)
  // 3. AdhanAlarmReceiver starts AdhanForegroundService (native Service)
  // 4. No Flutter code is involved in the alarm firing!
  final result = await AdhanService.schedule(
    alarmId: testAlarmId,
    scheduledTime: scheduledTime,
    soundPath: soundPath,
    title: title,
    body: body,
  );
  
  if (result) {
    print('✅ [TestAlarm] Alarm scheduled successfully for $scheduledTime');
  } else {
    print('❌ [TestAlarm] Failed to schedule alarm');
    TestAlarmState.clear();
  }
  
  return result;
}

/// Cancel the test alarm
Future<bool> cancelTestAlarm() async {
  print('🗑️ [TestAlarm] Cancelling alarm...');
  
  final result = await AdhanService.cancel(testAlarmId);
  TestAlarmState.clear();
  
  if (result) {
    print('✅ [TestAlarm] Alarm cancelled');
  } else {
    print('⚠️ [TestAlarm] No alarm to cancel or cancellation failed');
  }
  
  return result;
}

/// Check if alarm is scheduled (approximate - based on timing)
class TestAlarmState {
  static DateTime? _scheduledTime;
  
  static void setScheduledTime(DateTime time) {
    _scheduledTime = time;
  }
  
  static DateTime? get scheduledTime => _scheduledTime;
  
  static bool get isScheduled {
    if (_scheduledTime == null) return false;
    return _scheduledTime!.isAfter(DateTime.now());
  }
  
  static Duration? get remainingTime {
    if (_scheduledTime == null) return null;
    final remaining = _scheduledTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
  
  static void clear() {
    _scheduledTime = null;
  }
}
