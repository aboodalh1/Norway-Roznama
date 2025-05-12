import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../manger/monthly_timing_cubit.dart';

class MonthRow extends StatelessWidget {
  const MonthRow({
    super.key,
    required this.monthlyTimingCubit,
  });

  final MonthlyTimingCubit monthlyTimingCubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              monthlyTimingCubit.nextMonth();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
            )),
        Column(
          children: [
            Text(
              monthlyTimingCubit
                  .currentHijriDate.monthName,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff535763)),
            ),
            Text(
              monthlyTimingCubit
                  .currentHijriDate.year
                  .toString(),
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ],
        ),
        IconButton(
            onPressed: () {
              monthlyTimingCubit.prevMonth();
            },
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20.sp,
            )),
      ],
    );
  }
}
