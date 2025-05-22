import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';

import '../manger/halal_cubit.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key, required this.halalCubit});

  final HalalCubit halalCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: halalCubit,
        child: BlocBuilder<HalalCubit, HalalState>(
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    "قم بتمرير الباركود هنا",
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 16.sp),
                  ),
                ),
                body: MobileScanner(
                  controller: halalCubit.cameraController,
                  onDetect: halalCubit.handleBarcode,
                ),
                bottomSheet: Container(
                  height: 330.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(35.r),
                        topLeft: Radius.circular(35.r)),
                    color: const Color(0xffFFFFFF),
                  ),
                  width: double.infinity,
                  child: state is HalalLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        )
                      : state is HalalFailure
                          ? Center(
                              child: Text(state.error),
                            )
                          : Column(
                              children: [
                                Center(
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(vertical: 20.h),
                                    height: 10.h,
                                    width: 90.w,
                                    decoration: BoxDecoration(
                                        color: const Color(0xff535763),
                                        borderRadius:
                                            BorderRadius.circular(50.r)),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                ),
                                Text(
                                  'هذا المنتج:',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Center(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    width: 226.w,
                                    height: 162.h,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffDFDFDF),
                                        borderRadius:
                                            BorderRadius.circular(10.r)),
                                    child: halalCubit.isHalal != null
                                        ? Image.asset(
                                            halalCubit.isHalal!
                                                ? 'assets/img/halal_confirm.png'
                                                : 'assets/img/not_halal_confirm.png',
                                            height: 166.h,
                                            width: 152.w,
                                          )
                                        : const SizedBox(),
                                  ),
                                )
                              ],
                            ),
                ),
              ),
            );
          },
        ));
  }
}
