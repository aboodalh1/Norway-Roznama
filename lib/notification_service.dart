import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final _notification = FlutterLocalNotificationsPlugin();

  static init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notification.initialize(initSettings);

    // Create the notification channel with sound
    final androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Register the channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    tz.initializeTimeZones();
  }

  @pragma('vm:entry-point')
  static void showDailySchduledNotification(
      int id, String prayName, int hour, int minute,
      {String? soundPath}) async {
    AndroidNotificationDetails android = AndroidNotificationDetails(
      soundPath == "alafasi"
          ? "alafasi_channel"
          : soundPath == "alhusari"
              ? "alafasi_channel"
              : soundPath == "yaser"
                  ? "alafasi_channel"
                  : soundPath == "abd_albaset"
                      ? "alafasi_channel"
                      : 'High Importance alafasi_channel',
      soundPath == "alafasi"
          ? "alafasi"
          : soundPath == "alhusari"
              ? "alhusari"
              : soundPath == "yaser"
                  ? "yaser"
                  : soundPath == "abd_albaset" 
                      ? "abd_albaset"
                      : 'High Importance Notifications1',
      importance: Importance.max,
      priority: Priority.high,
      sound: soundPath?.replaceFirst(".mp3", "") != null
          ? UriAndroidNotificationSound(soundPath!.replaceFirst(".mp3", ""))
          : null,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      enableLights: true,
    );
  print(soundPath?.replaceFirst(".mp3", ""));
    DarwinNotificationDetails ios =
        DarwinNotificationDetails(sound: '$soundPath.mp3');
    NotificationDetails details =
        NotificationDetails(android: android, iOS: ios);
    tz.initializeTimeZones();
    String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    var currentTime = tz.TZDateTime.now(tz.local);

    var scheduleTime = tz.TZDateTime(tz.local, currentTime.year,
        currentTime.month, currentTime.day, hour, minute);

    if (scheduleTime.isBefore(currentTime)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      prayName,
      prayName,
      scheduleTime,
      details,
      payload: 'zonedSchedule',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @pragma('vm:entry-point')
  static void showWeeklyScheduledNotification(int id, String prayName,
      String soundPath, int hour, int minute, int dayOfWeek) async {
    AndroidNotificationDetails android = AndroidNotificationDetails(
      'weekly scheduled $id',
      'id $id',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('azan.mp3'),
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails ios = DarwinNotificationDetails();
    NotificationDetails details =
        NotificationDetails(android: android, iOS: ios);

    tz.initializeTimeZones();
    String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    var currentTime = tz.TZDateTime.now(tz.local);

    // Calculate the next occurrence of the specified day of week
    var scheduleTime = tz.TZDateTime(tz.local, currentTime.year,
        currentTime.month, currentTime.day, hour, minute);

    // Adjust to the next occurrence of the specified day of week
    while (scheduleTime.weekday != dayOfWeek ||
        scheduleTime.isBefore(currentTime)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    log("Weekly notification scheduled for: ${scheduleTime.toString()}");
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      prayName,
      prayName,
      scheduleTime,
      details,
      payload: 'weeklySchedule',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // This makes it repeat weekly
    );
  }

  @pragma('vm:entry-point')
  static void showMonthlyScheduledNotification(int id, String prayName,
      String soundPath, int hour, int minute, int dayOfMonth) async {
    AndroidNotificationDetails android = AndroidNotificationDetails(
      'weekly scheduled $id',
      'id $id',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('azan.mp3'),
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails ios = DarwinNotificationDetails();
    NotificationDetails details =
        NotificationDetails(android: android, iOS: ios);

    tz.initializeTimeZones();
    String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    var currentTime = tz.TZDateTime.now(tz.local);

    // Calculate the next occurrence of the specified day of week
    var scheduleTime = tz.TZDateTime(tz.local, currentTime.year,
        currentTime.month, currentTime.day, hour, minute);

    // Adjust to the next occurrence of the specified day of week
    while (scheduleTime.month != dayOfMonth ||
        scheduleTime.isBefore(currentTime)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    log("Weekly notification scheduled for: ${scheduleTime.toString()}");
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      prayName,
      prayName,
      scheduleTime,
      details,
      payload: 'weeklySchedule',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // This makes it repeat weekly
    );
  }

  @pragma('vm:entry-point')
  static void scheduleMultipleDaysMonthlyNotification(int id, String prayName,
      String soundPath, int hour, int minute, List<int> daysOfMonth) async {
    for (int i = 0; i < daysOfMonth.length; i++) {
      AndroidNotificationDetails android = AndroidNotificationDetails(
        'monthly scheduled ${id + i}',
        'id ${id + i}',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        sound: UriAndroidNotificationSound(soundPath),
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      const DarwinNotificationDetails ios = DarwinNotificationDetails();
      NotificationDetails details =
          NotificationDetails(android: android, iOS: ios);

      tz.initializeTimeZones();
      String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      var currentTime = tz.TZDateTime.now(tz.local);

      var scheduleTime = tz.TZDateTime(tz.local, currentTime.year,
          currentTime.month, daysOfMonth[i], hour, minute);

      if (scheduleTime.isBefore(currentTime)) {
        scheduleTime = tz.TZDateTime(tz.local, currentTime.year,
            currentTime.month + 1, daysOfMonth[i], hour, minute);
      }

      log("Monthly notification scheduled for: ${scheduleTime.toString()}");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + i,
        prayName,
        prayName,
        scheduleTime,
        details,
        payload: 'monthlySchedule',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  @pragma('vm:entry-point')
  static void scheduleDayOfSpecificMonthlyNotification(
      int id,
      String prayName,
      String soundPath,
      int hour,
      int minute,
      int month,
      List<int> daysOfMonth) async {
    for (int i = 0; i < daysOfMonth.length; i++) {
      AndroidNotificationDetails android = AndroidNotificationDetails(
        'monthly scheduled ${id + i}',
        'id ${id + i}',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound(soundPath),
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      const DarwinNotificationDetails ios = DarwinNotificationDetails();
      NotificationDetails details =
          NotificationDetails(android: android, iOS: ios);

      tz.initializeTimeZones();
      String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      var currentTime = tz.TZDateTime.now(tz.local);

      var scheduleTime = tz.TZDateTime(
          tz.local, currentTime.year, month, daysOfMonth[i], hour, minute);

      if (scheduleTime.isBefore(currentTime)) {
        scheduleTime = tz.TZDateTime(tz.local, currentTime.year, month + 1,
            daysOfMonth[i], hour, minute);
      }

      log("Monthly notification scheduled for: ${scheduleTime.toString()}");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + i,
        prayName,
        prayName,
        scheduleTime,
        details,
        payload: 'monthlySchedule',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  static void cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static void cancelAlllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

// Future<void> openBatteryOptimizationSettings() async {
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

//   if (androidInfo.version.sdkInt >= 23) {
//     AndroidIntent intent = AndroidIntent(
//       action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
//       package: 'your.package.name',
//     );
//     await intent.launch();
// }
// /}
