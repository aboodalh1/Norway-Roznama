
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/util/constant.dart';

class CustomColumnLabelText extends StatelessWidget {
  const CustomColumnLabelText({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 12.sp,  color: kPrimaryColor),
    );
  }
}
