import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/api_service.dart';
import 'package:norway_roznama_new_project/core/util/assets_loader.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/functions.dart';
import 'package:norway_roznama_new_project/features/home/presentation/view/home_page.dart';

import '../../../../core/util/constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Subscribe to the "all-clients" topic

  void subscribeToTopic() {
    _firebaseMessaging.subscribeToTopic('all-clients').then((_) {
    }).catchError((error) {
    });
  }

  // Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
  }

  void printToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      try {
        Dio dio = Dio();
        DioHelper(dio)
            .postData(endPoint: 'api/v1/devices', data: {"fcm_token": token});
        CacheHelper.saveData(key: 'fcmToken', value: token);
      } catch (e) {
      }
    }
  }

  Future<void> refreshFCMToken() async {
    try {
      // Delete the existing token
      await FirebaseMessaging.instance.deleteToken();

      // Get a new token
      final newToken = await FirebaseMessaging.instance.getToken();


      if (newToken != null) {
        // Save the new token
        await CacheHelper.saveData(key: 'fcmToken', value: newToken);
      }
    } catch (e) {
    }
  }

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();

    // Subscribe to the topic "all-clients"
    subscribeToTopic();
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Handle the foreground notification
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'No Title'),
              content: Text(message.notification!.body ?? 'No Body'),
            );
          },
        );
      }
    });

    // Handle background and terminated state messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    printToken();

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
    Future.delayed(Duration(seconds: 3)).then((value) {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: kPrimaryColor));
      navigateAndFinish(context,
          Directionality(textDirection: TextDirection.rtl, child: HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffE7FFE0),
                    Color(0xff4E903C),
                  ]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 77.w, left: 77.w, top: 285.h),
                child: Image.asset(AssetsLoader.logo),
              ),
              Spacer(),
              Image.asset(AssetsLoader.splashScreen),
            ],
          )
        ],
      ),
    );
  }
}
