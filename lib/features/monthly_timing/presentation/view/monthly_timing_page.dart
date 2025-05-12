import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/core/widgets/custom_snack_bar.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/presentation/view/widgets/backward_button.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/presentation/view/widgets/month_row.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/presentation/view/widgets/save_pdf_button.dart';

import '../manger/monthly_timing_cubit.dart';
import 'month_pray_timing_table.dart';

class MonthlyTimingPage extends StatelessWidget {
  const MonthlyTimingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MonthlyTimingCubit, MonthlyTimingState>(
      listener: (context, state) {
        if (state is SavePdfSuccess) {
          customSnackBar(context, state.message);
        }
        if (state is SavePdfFailure) {
          customSnackBar(context, state.error, color: Colors.red);
        }
      },
      builder: (context, state) {
        MonthlyTimingCubit monthlyTimingCubit =
            context.read<MonthlyTimingCubit>();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              leading: BackwardButton(),
              actions: [
                state is SavePdfLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 10.w),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : SavePdfButton(monthlyTimingCubit: monthlyTimingCubit,)
              ],
            ),
            body:  RepaintBoundary(
                    key: monthlyTimingCubit.screenshotKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                      child: Image.asset(
                                    'assets/img/timing_background.png',
                                    scale: 0.5,
                                  )),
                                  Positioned(
                                    bottom: 180.h,
                                    child: MonthRow(monthlyTimingCubit: monthlyTimingCubit),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 200.h),
                                child: InteractiveViewer(
                                  transformationController:
                                      monthlyTimingCubit.transformationController,
                                  minScale: 0.5,
                                  maxScale: 2.5,
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h, horizontal: 5.w),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(23.r),
                                            topLeft: Radius.circular(23.r),
                                          )),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(23.r),
                                          topRight: Radius.circular(23.r),
                                        ),
                                        child: state is GetMonthlyTimingLoading
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                color: kPrimaryColor,
                                              ))
                                            : MonthPrayTimingTable(monthlyTimingCubit: monthlyTimingCubit),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
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




