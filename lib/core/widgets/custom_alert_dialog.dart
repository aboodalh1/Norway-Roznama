import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void customAlertDialog(BuildContext context, {required String title,required List<Widget> actions}){
  showDialog(
    useSafeArea: false,
      context: context, builder: (context){
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        content: Text(title,style: TextStyle(fontSize:15.sp,),),
        actions: actions,
      ),
    );
  });
}