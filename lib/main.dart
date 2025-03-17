import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/splash_screen/presentation/view/splash_screen.dart';
import 'package:norway_roznama_new_project/worker_manger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'bloc_observer.dart';
import 'core/util/constant.dart';
import 'core/util/service_locator.dart';
import 'features/articles_and_stickers/data/repos/articles_repo_impl.dart';
import 'features/articles_and_stickers/presentation/manger/articles_cubit.dart';
import 'features/prays_and_times/prays_and_qiblah/data/repos/prays_repo_impl.dart';
import 'features/prays_and_times/prays_and_qiblah/presentation/manger/prays_cubit.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'features/prays_and_times/prays_settings/data/repo/adhan_repo_impl.dart';
import 'features/prays_and_times/prays_settings/presentation/manger/prays_settings_cubit.dart';
import 'firebase_options.dart';
import 'notification_service.dart';



class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void callbackDispatcher() async{
    final prefs = await SharedPreferences.getInstance();
  for(int i=0;i<6;i++){
    if(prefs.getInt('alarm_hour_$i')==null||prefs.getInt('alarm_minute_$i')==null){
  Workmanager().executeTask((task, inputData) async {
    final hour = prefs.getInt('alarm_hour');
    final minute = prefs.getInt('alarm_minute');

    if (hour != null && minute != null) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var androidDetails = AndroidNotificationDetails('alarm_channel', 'Alarm Notifications');
      var generalNotificationDetails = NotificationDetails(android: androidDetails);
      await flutterLocalNotificationsPlugin.show(0, 'Alarm!', 'It\'s time!', generalNotificationDetails);
    }
    return Future.value(true);
  });}}
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  await Future.wait([
    WorkManagerService().init(),
    LocalNotificationService.init(),
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true),
    CacheHelper.init()
  ]);
  HttpOverrides.global = MyHttpOverrides();
  setupServiceLocator();
  Bloc.observer = MyBlocObserver();
  if(CacheHelper.getData(key: 'lat')==null|| CacheHelper.getData(key: 'lon')==null){
    fetchLocation();
  }
  else {
    latitude=CacheHelper.getData(key: 'lat');
    longitude=CacheHelper.getData(key: 'lon');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
                PraysCubit(getIt.get<PraysRepoImpl>()),
          ),
          BlocProvider(
            create: (context) =>
                PraysSettingsCubit(getIt.get<AdhanRepoImpl>()),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
              timePickerTheme: TimePickerThemeData(
                  dialHandColor: kPinkColor,
                  dayPeriodTextColor: kPinkColor,
                  confirmButtonStyle: ButtonStyle(
                      foregroundColor:
                      WidgetStateProperty.all(const Color(0xff3E73BC))),
                  cancelButtonStyle: ButtonStyle(
                      foregroundColor:
                      WidgetStateProperty.all(const Color(0xff3E73BC))),
                  dayPeriodColor: const Color(0xffFFCDDE)),
              textSelectionTheme: TextSelectionThemeData(
                  selectionColor: kPrimaryColor,
                  selectionHandleColor: kPrimaryColor,
                  cursorColor: kPrimaryColor),
              fontFamily: 'Inter',
              appBarTheme: AppBarTheme(
                  elevation: 6,
                  shadowColor: Colors.black,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                  ),
                  backgroundColor: kPrimaryColor)),
          home: SplashScreen(),
        ),
      ),
    );
  }
}
