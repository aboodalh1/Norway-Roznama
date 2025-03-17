import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/constant.dart';


void customSnackBar(context,String text,{Color ?color,int? duration}){
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds:duration??4),
      backgroundColor: color ?? kPrimaryColor,
      content: Text(text, style: const TextStyle(fontSize:18),),
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsetsDirectional.symmetric(vertical: 10.h,horizontal: 10.w),
      margin:  EdgeInsets.only(bottom: 75.h,top: 20,left: 10,right: 10),

    ),
  );
}