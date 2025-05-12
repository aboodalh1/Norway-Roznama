import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/util/constant.dart';

class InternetCheckWidget extends StatelessWidget {
  const InternetCheckWidget({
    super.key,
     required this.text, required this.onTap,
  });

  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                  backgroundColor:
                  WidgetStateProperty.all(kPrimaryColor)),
              onPressed: onTap,
              child: Text(
                "اعادة المحاولة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ))
        ],
      ),
    );
  }
}