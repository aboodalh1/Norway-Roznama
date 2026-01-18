// // import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:norway_roznama_new_project/main.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// /// @deprecated This class uses AndroidAlarmManager with Dart callbacks which
// /// does NOT work when the app is terminated (MethodChannel fails).
// /// 
// /// Use [AdhanService.schedule()] from 'package:norway_roznama_new_project/core/audio/adhan_service.dart'
// /// instead, which uses native Android AlarmManager that works even when the app is terminated.
// /// 
// /// This class is kept for reference only and should not be used for new code.
// @Deprecated('Use AdhanService.schedule() instead - works when app is terminated')
// class AlarmService {
//   static bool _isInitialized = false;

//   static Future<void> initialize() async {
//     if (_isInitialized) return;
//     await AndroidAlarmManager.initialize();
//     _isInitialized = true;
//     print('✅ AlarmService initialized');
//   }

//   static Future<void> scheduleAlarm({
//     required int id,
//     required int hour,
//     required int minutes,
//     required String title,
//     required String body,
//     required String soundPath,
//   }) async {
//     if (!_isInitialized) await initialize();

//     // Clear any existing alarm state for this ID before scheduling a new one

//     tz.initializeTimeZones();
//     String currentTimeZone = await FlutterTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(currentTimeZone));
//     var currentTime = tz.TZDateTime.now(tz.local);

//     var scheduleTime = tz.TZDateTime(tz.local, currentTime.year,
//         currentTime.month, currentTime.day, hour, minutes);

//     if (scheduleTime.isBefore(currentTime)) {
//       scheduleTime = scheduleTime.add(const Duration(days: 1));
//     }

//     print('📅 Scheduling alarm with ID: $id at $scheduleTime');

//     // Schedule the alarm to trigger at the exact time
//     await AndroidAlarmManager.oneShotAt(
//       scheduleTime, // Use scheduleTime directly for accurate alarms
//       id,
//       alarmCallback,
//       exact: true,
//       wakeup: true,
//       alarmClock: true,
//       allowWhileIdle: true,
//       rescheduleOnReboot: true,
//       params: {
//         'id': id,
//         'title': title,
//         'minute': minutes,
//         'hour': hour,
//         'body': body,
//         'soundPath': soundPath,
//       },
//     );

//     // await Workmanager().registerPeriodicTask(
//     //   "task-identifier", "simpleTask",
//     //    initialDelay: Duration(seconds: 10),
//     //   backoffPolicy: BackoffPolicy.exponential,
//     //   backoffPolicyDelay: Duration(seconds: 10),
//     //    frequency: Duration(minutes: 15),
//     //    inputData: {
//     //     'id': id,
//     //     'title': title,
//     //     'minute': minutes,
//     //     'hour': hour,
//     //     'body': body,
//     //     'soundPath': soundPath,
//     //   },
//     // );

//     // if (result) {
//     print('✅ Alarm scheduled successfully for ID: $id');
//     // } else {
//     //   print('❌ Failed to schedule alarm for ID: $id');
//     // }
//   }

//   // static Future<void> cancelAlarm(int id) async {
//   //   await stopAlarmSound(1);
//   //   // Cancel the scheduled alarm
//   //   final bool success = await AndroidAlarmManager.cancel(id);
//   //
//   //
//   //   // Clear any existing alarm state for this ID
//   //   if (success) {
//   //     print('✅ Alarm cancelled with ID: $id');
//   //   } else {
//   //     print('❌ Failed to cancel alarm with ID: $id');
//   //   }
//   // }
// }
