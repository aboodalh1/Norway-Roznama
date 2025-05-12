import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/features/base_page/presentation/view/widgets/base_page_custom_card.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/data/local/prays_photo.dart';

import '../../../prays_and_times/prays_and_qiblah/presentation/manger/prays_cubit.dart';
import '../../../prays_and_times/prays_and_qiblah/presentation/view/widgets/nearest_time_clock.dart';

class BasePageBody extends StatelessWidget {
  const BasePageBody({
    super.key,
    required this.praysCubit,
  });

  final PraysCubit praysCubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 278.h,
            decoration: const BoxDecoration(color: Color(0xffD9D9D9)),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                      width: 390.w,
                      height: 278.h,
                      child: Image.asset(
                        PraysData.PraysPhoto[praysCubit.neartestPrayIndex],
                        fit: BoxFit.fill,
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      NearestTimeClock(praysCubit: praysCubit),
                      SizedBox(
                        height: 19.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${JHijri.now().dayName} ${JHijri.now().day} ${JHijri.now().monthName} ${JHijri.now().year}",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 16.w,
                  crossAxisCount: 3,
                  mainAxisSpacing: 25.h),
              itemBuilder: (context, index) {
                return CustomCard(praysCubit: praysCubit, index: index);
              },
              itemCount: 6,
            ),
          ),
          if(praysCubit.isOslo)Padding(
            padding:  EdgeInsets.symmetric(horizontal: 21.0.w,vertical: 20.h),
            child: Row(
              children: [
                Icon(Icons.warning_amber,color: Colors.red.withValues(alpha: 0.6),size: 24.sp,),
                Text("تنبيه:",style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w600,color: kBlackGrey),),
              ],
            ),
          ),
          if(praysCubit.isOslo)Text("أوقات الصلاة بتوقيت مدينة أوسلو، النرويج",style: TextStyle(fontSize: 17.sp,fontWeight: FontWeight.w600,color: kBlackGrey),)
        ],
      ),
    );
  }
}
