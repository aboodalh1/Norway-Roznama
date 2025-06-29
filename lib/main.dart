import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:just_audio/just_audio.dart';
import 'package:norway_roznama_new_project/alarm_service.dart';
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/data/repos/monthly_timing_repo_impl.dart';
import 'package:norway_roznama_new_project/features/splash_screen/presentation/view/splash_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'bloc_observer.dart';
import 'core/util/constant.dart';
import 'core/util/service_locator.dart';
import 'features/articles_and_stickers/data/repos/articles_repo_impl.dart';
import 'features/articles_and_stickers/presentation/manger/articles_cubit.dart';
import 'features/monthly_timing/presentation/manger/monthly_timing_cubit.dart';
import 'features/prays_and_times/prays_and_qiblah/data/repos/prays_repo_impl.dart';
import 'features/prays_and_times/prays_and_qiblah/presentation/manger/prays_cubit.dart';
import 'features/prays_and_times/prays_settings/data/repo/adhan_repo_impl.dart';
import 'features/prays_and_times/prays_settings/presentation/manger/prays_settings_cubit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

AudioPlayer? backgroundAudioPlayer;
Timer? alarmStopCheckTimer;


// Your callback dispatcher as defined above
@pragma('vm:entry-point')
void callbackDispatcher() {
     print("ffffffffff");
  Workmanager().executeTask((taskName, inputData) async {
   try{
     print("ffffffffff");
    WidgetsFlutterBinding.ensureInitialized();

    tz.initializeTimeZones();
    String currentTimeZone;
    try {
      currentTimeZone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      print(
          '❌ Could not get local timezone in background: $e. Defaulting to UTC.');
      currentTimeZone = 'UTC';
    }
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
      onNotificationResponse, // Use background handler
      onDidReceiveNotificationResponse: onNotificationTapped, // This is for foreground, not strictly needed here for background alarm.
    );

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'alarm_channel',
        'Alarm Notifications',
        description: 'Channel for alarm notifications',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.red,
        showBadge: true,
        playSound: false, // Notification sound is handled by JustAudio
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await _showAlarmNotification(
      id: inputData!['id']??1,
      minute: inputData['minute'] as int,
      hour: inputData['hour'] as int,
      title: inputData['title']?.toString() ?? 'Alarm',
      body: inputData['body']?.toString() ?? 'Time for prayer',
    );

    await _playAlarmSoundWithStopControl(
      id: inputData['id'],
      soundPath: inputData['soundPath']?.toString() ?? 'assets/sounds/alafasi.mp3',
    );

    print('✅ Alarm callback completed successfully for ID: ${inputData['id']}');
  } catch (e) {
    print('❌ Error in alarm callback: $e');
  }
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void alarmCallback(int id, Map<String, dynamic> params) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    tz.initializeTimeZones();
    String currentTimeZone;
    try {
      currentTimeZone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      print(
          '❌ Could not get local timezone in background: $e. Defaulting to UTC.');
      currentTimeZone = 'UTC';
    }
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onNotificationResponse, // Use background handler
      onDidReceiveNotificationResponse: onNotificationTapped, // This is for foreground, not strictly needed here for background alarm.
    );

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'alarm_channel',
        'Alarm Notifications',
        description: 'Channel for alarm notifications',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.red,
        showBadge: true,
        playSound: false, // Notification sound is handled by JustAudio
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

      await _showAlarmNotification(
        id: id,
        minute: params['minute'] as int,
        hour: params['hour'] as int,
        title: params['title']?.toString() ?? 'Alarm',
        body: params['body']?.toString() ?? 'Time for prayer',
      );

    await _playAlarmSoundWithStopControl(
      id: id,
      soundPath: params['soundPath']?.toString() ?? 'assets/sounds/alafasi.mp3',
    );

    print('✅ Alarm callback completed successfully for ID: $id');
  } catch (e) {
    print('❌ Error in alarm callback: $e');
  }
}

Future<void> _showAlarmNotification({
  required int id,
  required int hour,
  required int minute,
  required String title,
  required String body,
}) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_channel',
    'Alarm Notifications',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    enableLights: true,
    ledColor: const Color.fromARGB(255, 255, 0, 0),
    ledOnMs: 1000,
    ledOffMs: 500,
    ongoing: true,
    autoCancel: false,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.event,
    visibility: NotificationVisibility.public,
    actions: <AndroidNotificationAction>[
      // Ensure these action IDs are unique and handled correctly
      const AndroidNotificationAction(
        'stop_alarm_action', // Changed action ID for clarity
        'Stop Alarm',
        cancelNotification: true,
      ),
      const AndroidNotificationAction(
        'snooze_alarm_action', // Changed action ID for clarity
        'Snooze (5 min)',
        cancelNotification: false,
      ),
    ],
    setAsGroupSummary: false,
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: false,
    interruptionLevel: InterruptionLevel.critical,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: 'alarm_$id',
  );
}

Future<void> _playAlarmSoundWithStopControl({
  required int id,
  required String soundPath,
}) async {
  try {
    print('🔊 Starting to play alarm sound: $soundPath for ID: $id');

    await backgroundAudioPlayer?.stop();
    await backgroundAudioPlayer?.dispose();
    backgroundAudioPlayer = AudioPlayer();

    await backgroundAudioPlayer!.setAsset(soundPath);
    await backgroundAudioPlayer!.setLoopMode(LoopMode.one);
    await backgroundAudioPlayer!.setVolume(1.0);

    await backgroundAudioPlayer!.play();
    print('🎵 Alarm sound started playing for ID: $id');

    alarmStopCheckTimer?.cancel();
    alarmStopCheckTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        print('🛑 Stop request detected for alarm ID: $id');
        await stopAlarmSound(id);
        timer.cancel();
        return;
      } catch (e) {
        print('❌ Error in stop check timer: $e');
        timer.cancel();
      }
    });

    Timer(const Duration(seconds: 1), () async {
      print('⏰ Auto-stopping alarm after 3 minutes for ID: $id');
      await stopAlarmSound(id);
    });
  } catch (e) {
    print('❌ Error playing alarm sound: $e');
  }
}


Future<void> stopAlarmSound(int alarmId) async {
  try {
    print('🛑 Stopping alarm sound for ID: $alarmId');

    if (backgroundAudioPlayer != null) {
      await backgroundAudioPlayer!.stop();
      await backgroundAudioPlayer!.dispose();
      backgroundAudioPlayer = null;
    }
    alarmStopCheckTimer?.cancel();
    alarmStopCheckTimer = null;

    await flutterLocalNotificationsPlugin.cancel(alarmId);

    print('✅ Alarm sound stopped successfully for ID: $alarmId');
  } catch (e) {
    print('❌ Error stopping alarm sound: $e');
  }
}

void onNotificationTapped(NotificationResponse notificationResponse) async {
  print('📱 Notification tapped (foreground): ${notificationResponse.payload}');

  final alarmId = notificationResponse.id ?? 0;
  // await AlarmService.cancelAlarm(1);
  print('🛑 Stop alarm action triggered (foreground) for ID: $alarmId');

  await AndroidAlarmManager.oneShotAt(
    DateTime.now().add(Duration(
        milliseconds: 100)), // Use scheduleTime directly for accurate alarms
    1,
    alarmCallback,
    exact: true,
    wakeup: true,
    alarmClock: true,
    allowWhileIdle: true,
    rescheduleOnReboot: true,
    params: {
      'id': 1,
      'title': "",
      'minute': DateTime.now().hour,
      'hour': DateTime.now().hour,
      'body': "",
      'soundPath': 'soundPath',
    },
  );

}

@pragma('vm:entry-point')
void onNotificationResponse(NotificationResponse notificationResponse) async {
  print(
      '📱 Notification tapped (background/terminated): ${notificationResponse.payload}');

  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  String currentTimeZone;
  try {
    currentTimeZone = await FlutterTimezone.getLocalTimezone();
  } catch (e) {
    print(
        '❌ Could not get local timezone in background notification response: $e. Defaulting to UTC.');
    currentTimeZone = 'UTC';
  }
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  final alarmId = notificationResponse.id ?? 0;

  // if (notificationResponse.actionId == 'stop_alarm_action') {
  //   // Use updated action ID
  //   print('🛑 Stop alarm action triggered (background) for ID: $alarmId');
  // } else if (notificationResponse.actionId == 'snooze_alarm_action') {
  //   // Use updated action ID
  //   print('😴 Snooze alarm action triggered (background) for ID: $alarmId');

  // Schedule snooze
  // final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
  await AlarmService.scheduleAlarm(
    id: 1,
    hour: DateTime.now().hour,
    minutes: DateTime.now().minute,
    title: 'Snoozed Alarm',
    body: 'Snooze time is over',
    soundPath: 'assets/sounds/alafasi1.mp3',
  );
  // }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 Starting app initialization...');

    // Initialize timezones
    tz.initializeTimeZones();

    // Initialize local notifications plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          onNotificationTapped, // For foreground taps
      onDidReceiveBackgroundNotificationResponse:
          onNotificationTapped, // For background/terminated taps
    );

    // Initialize alarm service
    await AlarmService.initialize();

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false for production
    );
    // Request necessary permissions
    await requestPermissions();

    // Initialize Firebase
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize cache helper
    await CacheHelper.init();

    // Setup service locator
    setupServiceLocator();

    // Setup bloc observer
    Bloc.observer = MyBlocObserver();

    // Initialize location if not cached
    if (CacheHelper.getData(key: 'lat') == null ||
        CacheHelper.getData(key: 'lon') == null) {
      fetchLocation();
    } else {
      latitude = CacheHelper.getData(key: 'lat');
      longitude = CacheHelper.getData(key: 'lon');
    }

    print('✅ App initialization completed successfully');
    runApp(const MyApp());
  } catch (e) {
    print('❌ Error during app initialization: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Is24Format.init(context);
    return ScreenUtilInit(
      designSize: const Size(390, 854),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ArticlesCubit(getIt.get<ArticlesRepoImpl>())
              ..getSections()
              ..getArticles(number: 10),
          ),
          BlocProvider(
            create: (context) =>
                MonthlyTimingCubit(getIt.get<MonthlyTimingRepoImpl>())
                  ..getMonthlyTiming(
                    month: HijriDate.now().month,
                    year: HijriDate.now().year,
                  ),
          ),
          BlocProvider(
            create: (context) => PraysCubit(getIt.get<PraysRepoImpl>()),
          ),
          BlocProvider(
            create: (context) => PraysSettingsCubit(getIt.get<AdhanRepoImpl>()),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
            timePickerTheme: TimePickerThemeData(
              dialHandColor: kPinkColor,
              dayPeriodTextColor: kPinkColor,
              confirmButtonStyle: ButtonStyle(
                foregroundColor:
                    WidgetStateProperty.all(const Color(0xff3E73BC)),
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor:
                    WidgetStateProperty.all(const Color(0xff3E73BC)),
              ),
              dayPeriodColor: const Color(0xffFFCDDE),
            ),
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: kPrimaryColor,
              selectionHandleColor: kPrimaryColor,
              cursorColor: kPrimaryColor,
            ),
            fontFamily: 'Inter',
            appBarTheme: AppBarTheme(
              elevation: 6,
              shadowColor: Colors.black,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
              ),
              backgroundColor: kPrimaryColor,
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
