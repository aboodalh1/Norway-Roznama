import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/api_service.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/core/util/functions.dart';
import 'package:norway_roznama_new_project/features/home/presentation/view/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  /// Request all permissions after the first frame is rendered (only on first launch).
  /// This ensures the Activity is visible, preventing silent permission failures in release.
  /// Permissions are requested only once on first launch, stored in cache to avoid repeated requests.
  void _requestPermissionsAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if permissions were already requested on first launch
      final bool? permissionsRequested = CacheHelper.getData(key: 'permissions_requested');
      
      if (permissionsRequested != true) {
        // First launch - request all permissions together
        print('📱 First launch detected - requesting all permissions...');
        await requestPermissions();
        
        // Also fetch location after permissions are granted
        fetchLocation();
        
        // Mark permissions as requested to avoid future prompts
        await CacheHelper.saveData(key: 'permissions_requested', value: true);
        print('✅ Permissions requested and flag saved');
      } else {
        print('📱 Permissions already requested on previous launch');
      }
    });
  }
  
  // Subscribe to the "all-clients" topic

  void subscribeToTopic() {
    _firebaseMessaging.subscribeToTopic('all-clients').then((_) {
      print('Successfully subscribed to topic: all-clients');
    }).catchError((error) {
      // Topic subscription failed - app should continue to work
      print('Error subscribing to topic: $error');
    });
  }

  // Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
  }

  void printToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        try {
          Dio dio = Dio();
          DioHelper(dio)
              .postData(endPoint: 'api/v1/devices', data: {"fcm_token": token});
          CacheHelper.saveData(key: 'fcmToken', value: token);
        } catch (e) {
          // Error sending token to server, but token is still saved locally
          print('Error sending FCM token to server: $e');
        }
      }
    } catch (e) {
      // Firebase Messaging service not available
      // This can happen if Google Play Services is not available or network issues
      print('Error getting FCM token: $e');
      // App should continue to work without FCM token
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
      // Firebase Messaging service not available
      print('Error refreshing FCM token: $e');
      // App should continue to work without refreshing token
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Request permissions after UI is visible (prevents silent failures in release)
    _requestPermissionsAfterFrame();
    
    try {
      _firebaseMessaging.requestPermission();
    } catch (e) {
      print('Error requesting FCM permission: $e');
    }

    subscribeToTopic();
    
    // Listen for foreground messages with error handling
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (message.notification != null && mounted) {
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
      },
      onError: (error) {
        print('Error listening to FCM messages: $error');
      },
    );

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      print('Error setting up background message handler: $e');
    }
    
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
             color:Colors.white
            ),
          ),
          Center(child: Image.asset("assets/img/islamsk mojammaa -1.png",height: 300.h,width: 300.w,))
        ],
      ),
    );
  }
}
