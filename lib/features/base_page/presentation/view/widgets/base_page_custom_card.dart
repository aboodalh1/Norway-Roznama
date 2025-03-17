import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/presentation/view/prays_and_qiblah_page.dart';
import '../../../../../core/util/functions.dart';
import '../../../../articles_and_stickers/stickers/presentation/sticker_page.dart';
import '../../../../fasting/presentation/view/fasting_page.dart';
import '../../../../halal_food/presentation/view/halal_page.dart';
import '../../../../prays_and_times/prays_and_qiblah/presentation/manger/prays_cubit.dart';
import '../../../../prays_and_times/prays_and_qiblah/presentation/view/prays_settings.dart';
import '../../../../zakah/presentation/view/zakah_view.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({super.key, required this.praysCubit, required this.index});

  final PraysCubit praysCubit;
  final int index;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool isLight = true;
  List<String> images = [
    'assets/icons/praying.png',
    'assets/icons/zakat.png',
    'assets/icons/fasting.png',
    'assets/icons/haj.png',
    'assets/icons/halal_icon.png',
    'assets/icons/stickers_icon.png',
  ];
  List<String> titles = [
    'صلاة وقبلة',
    'الزكاة',
    'الصيام',
    'الحج والعمرة',
    'الأكلات الحلال',
    'الملصقات',
  ];
  List<Widget> screens = [
    PraysAndQiblahPage(),
    ZakahView(),
    FastingPage(),
    PraysSettings(),
    HalalPage(),
    StickersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

          navigateTo(context, screens[widget.index]);

      },
      child: Container(
          decoration: BoxDecoration(
              color: Color(0xffE6E6E6),
              borderRadius: BorderRadius.circular(10.r)),
          height: 111.h,
          width: 108.h,
          padding: EdgeInsets.all(6).w,
          child: Container(
            width: 99.w,
            height: 96.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Color(0xff91DE7F), width: 1.5.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(images[widget.index]),
                SizedBox(
                  height: 11.h,
                ),
                Text(
                  titles[widget.index],
                  style: TextStyle(
                      color: Color(0xff057107),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )),
    );
  }
}
