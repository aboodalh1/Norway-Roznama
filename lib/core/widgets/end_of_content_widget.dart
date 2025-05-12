import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EndOfContentWidget extends StatelessWidget {
  const EndOfContentWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          width: 190.w,
          height: 35.h,
          child: Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
              ))),
    );
  }
}