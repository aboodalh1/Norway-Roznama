import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/notification_service.dart';

class FastingDayTile extends StatefulWidget {
  const FastingDayTile({
    super.key,
    required this.dayName,
    required this.details,
    required this.index,
  });

  final List<String> dayName;
  final List<String> details;
  final int index;

  @override
  State<FastingDayTile> createState() => _FastingDayTileState();
}

bool whiteDays = CacheHelper.getData(key: "white_days") ?? false;
bool aashouraa = CacheHelper.getData(key: "aashouraa") ?? false;
bool arafat = CacheHelper.getData(key: "arafat") ?? false;

class _FastingDayTileState extends State<FastingDayTile> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffC0C0C0), width: 1),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Switch(
                        activeTrackColor: kPinkColor,
                        value: widget.index == 0
                            ? whiteDays
                            : widget.index == 1
                                ? aashouraa
                                : arafat,
                        onChanged: (value) async {
                          if (widget.index == 0) {
                            if (value) {
                              LocalNotificationService
                                  .scheduleMultipleDaysMonthlyNotification(
                                      13, "الاأيام البيض", '', 12, 0, [12]);
                              setState(() {
                                whiteDays = true;
                              });
                            } else {
                              LocalNotificationService.cancelNotification(13);
                              setState(() {
                                whiteDays = false;
                              });
                            }
                            await CacheHelper.saveData(
                                key: "white_days", value: whiteDays);
                          } else if (widget.index == 1) {
                            if (value) {
                              LocalNotificationService
                                  .scheduleDayOfSpecificMonthlyNotification(
                                      8, "عاشوراء", '', 12, 0, 11, [9]);
                              setState(() {
                                aashouraa = true;
                              });
                            } else {
                              LocalNotificationService.cancelNotification(8);
                              setState(() {
                                aashouraa = false;
                              });
                            }
                            CacheHelper.saveData(
                                key: "aashouraa", value: aashouraa);
                          }
                         else if  (widget.index == 2) {
                            if (value) {
                              LocalNotificationService
                                  .scheduleDayOfSpecificMonthlyNotification(
                                      8, "يوم عرفة", '', 12, 0, 11, [9]);
                              setState(() {
                                arafat = true;
                              });
                            }
                            else {
                              LocalNotificationService.cancelNotification(8);
                            setState(() {
                              arafat = false;
                            });
                          }
                          CacheHelper.saveData(key: "arafat", value: arafat);
                        }}),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        widget.dayName[widget.index],
                        style: TextStyle(
                            color: const Color(0xff3D3D3D),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.details[widget.index],
                        style: TextStyle(
                            color: const Color(0xff7F7F7F),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
