import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/util/constant.dart';
import '../../manger/prays_cubit.dart';

class InternetCheckWidget extends StatelessWidget {
  const InternetCheckWidget({
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
            "تأكد من اتصالك بالانترنت ثم حاول مرة اخرى",
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                  WidgetStateProperty.all(kPrimaryColor)),
              onPressed: () {
                praysCubit.getPrays();
              },
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