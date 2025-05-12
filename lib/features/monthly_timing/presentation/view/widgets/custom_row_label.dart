import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomRowLabel extends StatelessWidget {
  const CustomRowLabel({super.key, required this.timing});

  final String timing;

  @override
  Widget build(BuildContext context) {
    return Text(
      timing,
      style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.normal),
    );
  }
}
