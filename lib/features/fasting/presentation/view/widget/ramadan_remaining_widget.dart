import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/jHijri.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';

class RamadanRemainingWidget extends StatelessWidget {
  const RamadanRemainingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 35.0.h, horizontal: 20.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Row(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "المتبقي لرمضان",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.sp,
                      color: Color(0xff4D4D4D)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffD9D9D9),
                    borderRadius: BorderRadius.circular(13.r)),
                width: 106.w,
                height: 66.h,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "يوم",
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Text(
                        "12",
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xffD4FBCE),
                        borderRadius: BorderRadius.circular(13.r)),
                    width: 106.w,
                    height: 66.h,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "شهر",
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            "01",
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: -20.h,
                      left: -15.w,
                      child: Image.asset(
                        'assets/img/ramadan.png',
                        height: 35.h,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RamadanWidget extends StatelessWidget {
  const RamadanWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 35.0.h, horizontal: 20.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Row(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "التاريخ الهجري",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Color(0xff4D4D4D)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xffD4FBCE),
                        borderRadius: BorderRadius.circular(13.r)),
                    width: 205.w,
                    height: 66.h,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${JHijri.now().day}",
                            style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                                color: kPrimaryColor),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            JHijri.now().monthName,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: kPrimaryColor),
                          ),
                          SizedBox(
                            width: 9.w,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff535763)),
                            width: 5.w,
                            height: 5.h,
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            HijriDate.now().dayName,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff545763)),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: -20.h,
                      left: -15.w,
                      child: Image.asset(
                        'assets/img/ramadan.png',
                        height: 35.h,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
