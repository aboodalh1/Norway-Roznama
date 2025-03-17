import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextButton extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback function;
  const CustomTextButton(
      {super.key,
        required this.title,
        required this.icon,
        required this.function});

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      height: 60.h,
      child: TextButton(
          onPressed: function,
          child: Row(
            children: [
              Image.asset(icon,width: 24.w,height: 24.h,),
              SizedBox(
                width: 10.h,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w200,
                    color: Colors.black),
              )
            ],
          )),
    );
  }
}