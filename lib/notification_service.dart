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
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    tz.initializeTimeZones();
  }

  //basic Notification
  static void showBasicNotification(
    {required String soundPath }
  ) async {
          AndroidNotificationDetails android = AndroidNotificationDetails(
      'id 1', 'basic notification',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound(
        "yaser"
      ),
      priority: Priority.high,

    );
    NotificationDetails details = NotificationDetails(
      android: android,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'تم تعيين منبه الصلاة بنجاح',
      'اسم الصلاة',
      details,
      payload: "Payload Data",
    );
  }

  // //showRepeatedNotification
  // static void showRepeatedNotification() async {
  //   const AndroidNotificationDetails android = AndroidNotificationDetails(
  //     'id 2',
  //     'repeated notification',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   NotificationDetails details = const NotificationDetails(
  //     android: android,
  //   );
  //   await flutterLocalNotificationsPlugin.periodicallyShow(
  //     1,
  //     'Reapated Notification',
  //     'body',
  //     RepeatInterval.daily,
  //     details,
  //     payload: "Payload Data",
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  // //showSchduledNotification
  // static void showSchduledNotification() async {
  //   const AndroidNotificationDetails android = AndroidNotificationDetails(
  //     'schduled notification',
  //     'id 3',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   NotificationDetails details = const NotificationDetails(
  //     android: android,
  //   );
  //   tz.initializeTimeZones();
  //   log(tz.local.name);
  //   log("Before ${tz.TZDateTime.now(tz.local).hour}");
  //   final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  //   log(currentTimeZone);
  //   tz.setLocalLocation(tz.getLocation(currentTimeZone));
  //   log(tz.local.name);
  //   log("After ${tz.TZDateTime.now(tz.local).hour}");
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     2,
  //     'Schduled Notification',
  //     'body',
  //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
  //     details,
  //     payload: 'zonedSchedule',
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  @pragma('vm:entry-point')
  static void showDailySchduledNotification(
      int id, String prayName, int hour, int minute,
      {String? soundPath}) async {
    AndroidNotificationDetails android = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: soundPath!=null?
      RawResourceAndroidNotificationSound(
          soundPath):null,
      icon: '@mipmap/ic_launcher',
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

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'daily_prayer_channel',
    'Daily Prayer Notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('azan.mp3'),
    showBadge: true,
  );

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
