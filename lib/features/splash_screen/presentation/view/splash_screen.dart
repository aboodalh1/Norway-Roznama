import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/assets_loader.dart';
import 'package:norway_roznama_new_project/core/util/functions.dart';
import 'package:norway_roznama_new_project/features/home/presentation/view/home_page.dart';

import '../../../../core/util/constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
     SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark
          ));
    Future.delayed(Duration(seconds: 3)).then((value) {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: kPrimaryColor
          ));
      navigateAndFinish(context, Directionality(textDirection: TextDirection.rtl,
          child: HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
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
                padding:  EdgeInsets.only(right: 77.w,left: 77.w,top: 285.h),
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
