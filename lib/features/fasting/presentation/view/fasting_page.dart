import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/fasting/presentation/view/widget/fasting_day_tile.dart';
import 'package:norway_roznama_new_project/features/fasting/presentation/view/widget/fasting_notify_tile.dart';
import 'package:norway_roznama_new_project/features/fasting/presentation/view/widget/ramadan_remaining_widget.dart';


class FastingPage extends StatefulWidget {
  const FastingPage({super.key});

  @override
  State<FastingPage> createState() => _FastingPageState();
}

class _FastingPageState extends State<FastingPage> {
  List<String> dayNam = [
    "الأيام البيض",
    "عاشوراء",
    "عرفة",
  ];
  List<String> details = [
    "13-14-15 من كل شهر",
    "العاشر من محرم",
    "التاسع من ذي الحجة",
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Color(0xffFFFFFF),
                  size: 23.sp,
                )),
            title: Text(
              "إعدادات الصيام",
              style: TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                RamadanWidget(),
                SizedBox(
                  height: 35.h,
                ),
                FastingNotifyTile(),
                SizedBox(
                  height: 35.h,
                ),
                SizedBox(
                  child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 12.h,
                        );
                      },
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return FastingDayTile(
                          dayName: dayNam,
                          details: details,
                          index: index,
                        );
                      }),
                )
              ],
            ),
          ),
        ));
  }
}

