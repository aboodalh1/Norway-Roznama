import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/functions.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/presentation/view/widgets/internet_check_widget.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/presentation/view/widgets/pray_card.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/presentation/view/prays_settings.dart';
import '../../../../../core/util/constant.dart';
import '../../qiblah/presentation/view/qiblah_card.dart';
import '../manger/prays_cubit.dart';

class PraysAndQiblahPage extends StatelessWidget {
  const PraysAndQiblahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<PraysCubit, PraysState>(
        builder: (context, state) {
          PraysCubit praysCubit = context.read<PraysCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "الصلاة والقبلة",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400),
              ),
              leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              actions: [
                IconButton(
                  tooltip: 'تحديث الأوقات',
                  onPressed: () {
                    praysCubit.getPrays();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                IconButton(
                  tooltip: 'اعدادات التنبيهات',
                  onPressed: () {
                    navigateTo(context, PraysSettings());
                  },
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            body: state is GetPraysTimesLoading || state is LocationLoadingState
                ? PrayOrLocationLoadingWidget()
                : state is GetPrayersTimesError
                    ? InternetCheckWidget(
                        text: state.error, onTap: (){
              praysCubit.getPrays();
            })
                    : state is LocationMissedState ||
                            state is LocationFailureState
                        ? InternetCheckWidget(
                            text: "نحتاج إلى بيانات الموقع",
                            onTap: () {
                              praysCubit.requestLocation();
                            },
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                QiblahCard(),
                                if (praysCubit.isOslo)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 21.0.w, vertical: 8.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber,
                                          color:
                                              Colors.red.withValues(alpha: 0.6),
                                          size: 24.sp,
                                        ),
                                        Text(
                                          "تنبيه:",
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w600,
                                              color: kBlackGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (praysCubit.isOslo)
                                  Text(
                                    "أوقات الصلاة بتوقيت مدينة أوسلو، النرويج",
                                    style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w600,
                                        color: kBlackGrey),
                                  ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 10.h),
                                  itemBuilder: (context, index) {
                                    return PrayCard(
                                        praysCubit: praysCubit, index: index);
                                  },
                                  itemCount: 6,
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12.0.h),
                                  child: Center(
                                    child: SizedBox(
                                        width: 115.w,
                                        child: PrayCard(
                                            praysCubit: praysCubit, index: 6)),
                                  ),
                                ),
                              ],
                            ),
                          ),
          );
        },
      ),
    );
  }
}

class PrayOrLocationLoadingWidget extends StatelessWidget {
  const PrayOrLocationLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: kPrimaryColor,
      ),
    );
  }
}
