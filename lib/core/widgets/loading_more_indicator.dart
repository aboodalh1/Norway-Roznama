import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/constant.dart';

class LoadingMoreIndicator extends StatelessWidget {
  const LoadingMoreIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          width: 30.w,
          height: 35.h,
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          )),
    );
  }
}