import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/util/constant.dart';
import '../../../../../../core/util/functions.dart';
import '../../manger/prays_cubit.dart';
import '../prays_settings.dart';

class PrayCard extends StatefulWidget {
  const PrayCard({super.key, required this.praysCubit, required this.index});

  final PraysCubit praysCubit;
  final int index;

  @override
  State<PrayCard> createState() => _PrayCardState();
}

class _PrayCardState extends State<PrayCard> {
  bool isLight = true;
  List<String> praysImage = [
    "assets/img/fajr.png",
    "assets/img/sunrise.png",
    "assets/img/zohr.png",
    "assets/img/asr.png",
    "assets/img/sunset.png",
    "assets/img/isha.png",
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132.h,
      width: 115.h,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7.r),
                    child: Image.asset(praysImage[widget.index]),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        widget.praysCubit.praysName[widget.index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ), Text(
                        textAlign: TextAlign.center,
                        widget.praysCubit.stringPraysTimes[widget.index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
          GestureDetector(
            onLongPress: () {
              navigateTo(context, const PraysSettings());
            },
            child: IconButton(
                onPressed: () {
                  if (prayList[widget.index].isNotify) {
                    widget.praysCubit.updateFaredaNotify(false, widget.index);
                  }
                  else if (!prayList[widget.index].isNotify) {
                    widget.praysCubit.updateFaredaNotify(true, widget.index);
                  }
                },
                icon: Icon(
                  Icons.notifications,
                  color: prayList[widget.index].isNotify
                      ? kPinkColor
                      : kBlackGreyColor,
                )),
          )
        ],
      ),
    );
  }
}
