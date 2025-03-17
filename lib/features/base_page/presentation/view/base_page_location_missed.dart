import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/util/constant.dart';
import '../../../prays_and_times/prays_and_qiblah/presentation/manger/prays_cubit.dart';

class BasePageLocationMissed extends StatelessWidget {
  const BasePageLocationMissed({
    super.key,
    required this.praysCubit,
  });

  final PraysCubit praysCubit;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "نحتاج إلى بيانات الموقع",
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 45.h,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                  backgroundColor:
                  WidgetStateProperty.all(kPrimaryColor),
                ),
                onPressed: () {
                  Permission.location.request();
                  praysCubit.requestLocation();
                },
                child: Text(
                  "سماح",
                  style: TextStyle(
                      color: Colors.white, fontSize: 15.sp),
                ),
              )
            ]));
  }
}