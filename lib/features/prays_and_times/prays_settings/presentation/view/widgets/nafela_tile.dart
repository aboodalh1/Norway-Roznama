import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as Intl;
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/presentation/view/widgets/reader_choose_dialog.dart';
import 'package:norway_roznama_new_project/notification_service.dart';

import '../../../../../../core/util/constant.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';

class NafelaTile extends StatefulWidget {
  const NafelaTile({
    super.key,
    required this.index,
  });


  final int index;
  @override
  State<NafelaTile> createState() => _NafelaTileState();
}

class _NafelaTileState extends State<NafelaTile> {
  DateTime? selectedTime;
  List<String> nawafilName = [
    "الجمعة",
    "الضحى",
    "قيام الليل",
    "التهجد",
    "الأوّابين",
  ];

  void scheduleNotification(TimeOfDay time) {
    if (nawafelList[widget.index].isNotify && widget.index != 0) {
      LocalNotificationService.showDailySchduledNotification(
        widget.index +
            100, // Using offset to avoid conflicts with prayer notifications
        nawafilName[widget.index],
        time.hour,
        time.minute,
      );
    }
  }
  @override
  void initState() {
    super.initState();
    selectedTime = DateTime.now();
    if(CacheHelper.getData(key: "nafila_${widget.index}")!=null){
      nawafelList[widget.index].isNotify=CacheHelper.getData(key: "nafila_${widget.index}");
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PraysCubit, PraysState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0.h),
            child: GestureDetector(
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                if (pickedTime != null) {
                  final now = DateTime.now();
                  setState(() {
                    selectedTime = DateTime(now.year, now.month, now.day,
                        pickedTime.hour, pickedTime.minute);
                  });
                  // scheduleNotification(pickedTime);
                }
              },
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
                              value: nawafelList[widget.index].isNotify,
                              onChanged: (value) {
                                setState(() {
                                  nawafelList[widget.index].isNotify = value;
                                });
                                if (value && selectedTime != null) {
                                  scheduleNotification(TimeOfDay(
                                    hour: selectedTime!.hour,
                                    minute: selectedTime!.minute,
                                  ));
                                } else {
                                  LocalNotificationService.cancelNotification(
                                      widget.index + 100);
                                }
                                CacheHelper.saveData(key: "nafila_${widget.index}", value: value);
                              }
                              ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Text(
                              nawafilName[widget.index],
                              style: TextStyle(
                                  color: const Color(0xff3D3D3D),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              Is24Format.is24TimeFormat
                                  ? Intl.DateFormat("HH:mm")
                                      .format(selectedTime ?? DateTime.now())
                                  : Intl.DateFormat("hh:mm a")
                                      .format(selectedTime ?? DateTime.now()),
                              style: TextStyle(
                                  color: const Color(0xff3D3D3D),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18.h,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const ReaderChooseDialog();
                            });
                      },
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            Text(
                              "صوت المنبه",
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              context.read<PraysCubit>().lastReader,
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 24.w,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 20.sp,
                              color: const Color(0xff535763),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
