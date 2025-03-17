import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/presentation/view/widgets/internet_check_widget.dart';
import '../../../../../core/util/constant.dart';
import '../../../prays_settings/presentation/manger/prays_settings_cubit.dart';
import '../../../prays_settings/presentation/view/widgets/nawafel_list.dart';
import '../../../prays_settings/presentation/view/widgets/prayers_big_clock.dart';
import '../../../prays_settings/presentation/view/widgets/prayers_time_menu.dart';
import '../manger/prays_cubit.dart';

class PraysSettings extends StatelessWidget {
  const PraysSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PraysSettingsCubit, PraysSettingsState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        return BlocConsumer<PraysCubit, PraysState>(
          listener: (context, state) {},
          builder: (context, state) {
            PraysCubit praysCubit = context.read<PraysCubit>();
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(
                  leading: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 25.sp,
                      )),
                  title: Text(
                    "اعدادات الصلاة",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
                body: state is GetPrayersTimesError
                    ? InternetCheckWidget(praysCubit: praysCubit)
                    : Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.0.w, vertical: 30.h),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "تفعيل التنبيهات",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(3),
                              width: 35.w,
                              height: 34.h,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(color: kPrimaryColor)),
                              child: Text(
                                "pdf",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10.sp,
                                    color: kPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                        state is GetPraysTimesLoading
                            ? CircularProgressIndicator(
                          color: kPrimaryColor,
                        )
                            : state is GetPrayersTimesError
                            ? SizedBox(
                          child: Text(state.error),
                        )
                            : FaraedClocksRow(praysCubit: praysCubit),
                        SizedBox(
                          height: 40.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 24.w,
                                    vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Color(0xffD9D9D9).withOpacity(0.5),
                                  border: Border.all(
                                      color: Color(0xffC0C0C0), width: 1),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                margin: EdgeInsets.only(bottom: 14.h),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "الفرائض",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const Spacer(),
                                        Switch(
                                          value: context.read<PraysSettingsCubit>()
                                              .switchValue,
                                          activeTrackColor: kPinkColor,
                                          onChanged: (bool value) {
                                            context
                                                .read<PraysCubit>()
                                                .changeSwitchValue(value);
                                          },
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<PraysSettingsCubit>().isExpand
                                            ? context.read<PraysSettingsCubit>().changeExpand(false)
                                            : context.read<PraysSettingsCubit>().changeExpand(true);
                                      },
                                      child: Icon(
                                        context.read<PraysSettingsCubit>().isExpand
                                            ? Icons.keyboard_arrow_up_outlined
                                            : Icons
                                            .keyboard_arrow_down_outlined,
                                        size: 20.sp,
                                        color: const Color(0xff535763),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FareedaSettingsList(
                                praysSettingsCubit: context.read<PraysSettingsCubit>(),
                                praysCubit: context.read<PraysCubit>(),
                              ),
                              NawafelList()
                            ],
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
      },
    );
  }
}

class FaraedClocksRow extends StatelessWidget {
  const FaraedClocksRow({
    super.key,
    required this.praysCubit,
  });

  final PraysCubit praysCubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: const Color(0xff3E73BC),
              size: 25.sp),
          onPressed: () {
            praysCubit.pageController
                .previousPage(
                duration: const Duration(
                    milliseconds: 400),
                curve: Curves.easeInOut);
          },
        ),
        SizedBox(
          height: 240.h,
          width: 240.w,
          child: PageView(
              controller:
              praysCubit.pageController,
              children: List.generate(
                  context
                      .read<PraysCubit>()
                      .praysName
                      .length,
                      (index) =>
                      PrayerBigClock(
                        index: index,
                        praysCubit: context
                            .read<PraysCubit>(),
                      ))),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xff3E73BC),
            size: 25.sp,
          ),
          onPressed: () {
            praysCubit.pageController.nextPage(
                duration: const Duration(
                    milliseconds: 400),
                curve: Curves.easeInOut);
          },
        ),
      ],
    );
  }
}




