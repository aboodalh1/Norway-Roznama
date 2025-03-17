
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/util/constant.dart';
import '../../../prays_and_times/prays_and_qiblah/presentation/manger/prays_cubit.dart';

class BasePagePraysError extends StatelessWidget {
  const BasePagePraysError({
    super.key,
    required this.praysCubit, required this.error,
  });

  final PraysCubit praysCubit;
  final String error;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error),
          SizedBox(
            height: 20.h,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                  WidgetStateProperty.all(kPrimaryColor)),
              onPressed: () {
                praysCubit.getPrays();
              },
              child: Text(
                "إعادة المحاولة",
                style: TextStyle(
                    fontSize: 14.sp, color: Colors.white),
              ))
        ],
      ),
    );
  }
}