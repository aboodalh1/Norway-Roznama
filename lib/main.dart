import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:norway_roznama_new_project/core/audio/adhan_audio_handler.dart';
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
import 'dart:io';

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

// Your callback dispatcher as defined above
@pragma('vm:entry-point')
void callbackDispatcher() {
  print("ffffffffff");
  Workmanager().executeTask((taskName, inputData) async {
    try {
      print("ffffffffff");
      WidgetsFlutterBinding.ensureInitialized();

      await initAdhanAudioHandler();

      final alarmId = inputData?['id'] ?? 1;
      final title = inputData?['title']?.toString() ?? 'Alarm';
      final body = inputData?['body']?.toString() ?? 'Time for prayer';
      final soundPath =
          inputData?['soundPath']?.toString() ?? 'assets/sounds/alafasi.mp3';

      await AdhanAudioController.playAdhan(
        id: alarmId,
        title: title,
        body: body,
        soundPath: soundPath,
      );

      print('✅ Alarm callback completed successfully for ID: $alarmId');
    } catch (e) {
      print('❌ Error in alarm callback: $e');
    }
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void alarmCallback(int id, Map<String, dynamic> params) async {
  // #region agent log
  try {
    final logFile = File(
        r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
    await logFile.writeAsString(
      '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"alarm-callback","hypothesisId":"A","location":"main.dart:66","message":"alarmCallback entry","data":{"id":id,"params":params.toString()},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
  // #endregion

  print('🔔 [alarmCallback] Alarm triggered - ID: $id');

  try {
    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"alarm-callback","hypothesisId":"A","location":"main.dart:75","message":"Before WidgetsFlutterBinding","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    WidgetsFlutterBinding.ensureInitialized();
    print('✅ [alarmCallback] WidgetsFlutterBinding initialized');

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"alarm-callback","hypothesisId":"B","location":"main.dart:85","message":"Before initAdhanAudioHandler","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    await initAdhanAudioHandler();
    print('✅ [alarmCallback] Audio handler initialized');

    final title = params['title']?.toString() ?? 'Alarm';
    final body = params['body']?.toString() ?? 'Time for prayer';
    final soundPath =
        params['soundPath']?.toString() ?? 'assets/sounds/alafasi.mp3';

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"alarm-callback","hypothesisId":"C","location":"main.dart:100","message":"Before playAdhan","data":{"soundPath":soundPath},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    await AdhanAudioController.playAdhan(
      id: id,
      title: title,
      body: body,
      soundPath: soundPath,
    );

    print(
        '✅ [alarmCallback] Alarm callback completed successfully for ID: $id');

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"alarm-callback","hypothesisId":"C","location":"main.dart:115","message":"playAdhan completed","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion
  } catch (e, stackTrace) {
    print('❌ [alarmCallback] Error in alarm callback: $e');
    print('Stack trace: $stackTrace');

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"alarm-callback","hypothesisId":"A","location":"main.dart:125","message":"Error in alarmCallback","data":{"error":e.toString(),"errorType":e.runtimeType.toString(),"stackTrace":stackTrace.toString()},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion
  }
}

void onNotificationTapped(NotificationResponse notificationResponse) async {
  print('📱 Notification tapped (foreground): ${notificationResponse.payload}');

  final alarmId = notificationResponse.id ?? 0;
  print('🛑 Stop alarm action triggered (foreground) for ID: $alarmId');
  await AdhanAudioController.stopAdhan();
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

  print(
      '🛑 Stop alarm action triggered (background/terminated) for ID: $alarmId');
  await AdhanAudioController.stopAdhan();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // #region agent log
  try {
    final logFile = File(
        r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
    await logFile.writeAsString(
      '{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"main.dart:126","message":"main entry - WidgetsFlutterBinding done","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
  // #endregion

  try {
    print('🚀 Starting app initialization...');

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"main.dart:135","message":"Before timezone init","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

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

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"main.dart:161","message":"Before AlarmService.initialize","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // Initialize alarm service
    // await AlarmService.initialize();

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"main.dart:164","message":"Skipping initAdhanAudioHandler in main - will be lazy initialized","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // NOTE: AudioService initialization is deferred until first playback
    // This avoids FlutterEngine errors when called before runApp()

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // false for production (Release mode)
    );
    // NOTE: Permissions are now requested in SplashScreen after UI is visible
    // This prevents silent permission failures in release mode

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"C","location":"main.dart:175","message":"Before Firebase.initializeApp","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // Initialize Firebase
    await Firebase.initializeApp();

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"C","location":"main.dart:186","message":"After Firebase.initializeApp","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

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

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"main.dart:200","message":"Before runApp","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    print('✅ App initialization completed successfully');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"main.dart:210","message":"Error in main catch block","data":{"error":e.toString(),"errorType":e.runtimeType.toString(),"stackTrace":stackTrace.toString()},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    print('❌ Error during app initialization: $e');

    // Ensure Firebase is initialized even if other initialization failed
    try {
      await Firebase.initializeApp();
      print('✅ Firebase initialized in catch block');
    } catch (firebaseError) {
      print('❌ Failed to initialize Firebase in catch block: $firebaseError');
    }

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
