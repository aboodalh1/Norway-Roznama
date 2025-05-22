import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/data/repos/monthly_timing_repo_impl.dart';
import 'package:norway_roznama_new_project/features/splash_screen/presentation/view/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Request permission to send notifications
  if(await Permission.notification.isDenied){

  Permission.notification.request();
  }
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await LocalNotificationService.init();
  await LocalNotificationService.flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  await Future.wait([
    // LocalNotificationService.init(),
    CacheHelper.init(),
  ]);
  setupServiceLocator();
  Bloc.observer = MyBlocObserver();
  if (CacheHelper.getData(key: 'lat') == null ||
      CacheHelper.getData(key: 'lon') == null) {
    fetchLocation();
  } else {
    latitude = CacheHelper.getData(key: 'lat');
    longitude = CacheHelper.getData(key: 'lon');
  }
  runApp(const MyApp());

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
                    ..getMonthlyTiming(month: HijriDate.now().month,
                        year: HijriDate.now().year)),
          BlocProvider(create: (context) {
            return PraysCubit(getIt.get<PraysRepoImpl>());
          }),
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
