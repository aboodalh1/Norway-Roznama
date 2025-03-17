import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/util/constant.dart';
import '../../../../core/util/service_locator.dart';
import '../../../../core/widgets/custom_alert_dialog.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../data/repos/advice_repo_impl.dart';
import '../manger/advice_cubit.dart';

class AdvicePage extends StatelessWidget {
  const AdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => AdviceCubit(getIt.get<AdviceRepoImpl>()),
        child: BlocConsumer<AdviceCubit, AdviceState>(
          listener: (context, state) {
            if (state is SentValidationFailure) {
              customSnackBar(context, state.error, color: Colors.red);
            }
            if (state is SentAdviceSuccess) {
              customAlertDialog(context,
                  title: "تم إرسال النصيحة بنجاح",
                  actions: [
                    TextButton(
                        onPressed: () {
                          context.read<AdviceCubit>().messageController.clear();
                          context.read<AdviceCubit>().nameController.clear();
                          context.read<AdviceCubit>().emailController.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "تم",
                          style:
                              TextStyle(color: kPrimaryColor, fontSize: 16.sp),
                        ))
                  ]);
            }
            if (state is SentAdviceFailure) {
              if(state.error.contains('Validation')){
                customSnackBar(context, "يرجى إدخال معلومات صالحة",color: Colors.red,duration: 10);
              }
              else {customAlertDialog(context, title: state.error, actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "إلغاء",
                      style: TextStyle(fontSize: 16.sp, color: Colors.black),
                    )),
                TextButton(
                    onPressed: () {
                      context.read<AdviceCubit>().sentAdvice();
                      Navigator.of(context).pop();
                    },
                    child: Text("إعادة المحاولة",
                        style:
                            TextStyle(color: kPrimaryColor, fontSize: 16.sp))),
              ]);}
            }
          },
          builder: (BuildContext context, AdviceState state) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: 30.sp,
                      color: Colors.white,
                    )),
                title: Text(
                  "نصيحة لنا",
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50.h),
                      Text(
                        "الاسم",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      TextFormField(
                        controller: context.read<AdviceCubit>().nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: kGreyColor,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: BorderSide(color: kGreyColor)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: BorderSide(color: kGreyColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: BorderSide(color: kGreyColor)),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      Text(
                        "البريد الالكتروني",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      TextFormField(
                        controller: context.read<AdviceCubit>().emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: kGreyColor,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: BorderSide(color: kGreyColor)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: BorderSide(color: kGreyColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              borderSide: BorderSide(color: kGreyColor)),
                        ),
                      ),
                      SizedBox(
                        height: 53.h,
                      ),
                      Container(
                        decoration: BoxDecoration(color: kGreyColor),
                        height: 250.h,
                        width: 450.w,
                        child: TextFormField(
                          controller:
                              context.read<AdviceCubit>().messageController,
                          maxLines: 100,
                          decoration: InputDecoration(
                            hintText: "كيف يمكننا تحسين تجربتك ؟",
                            filled: true,
                            fillColor: kGreyColor,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(color: kGreyColor)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(color: kGreyColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(color: kGreyColor)),
                          ),
                        ),
                      ),
                      SizedBox(height: 80.h,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0.h),
                        child: Center(
                          child: SizedBox(
                            width: 355.w,
                            height: 46.h,
                            child: BlocBuilder<AdviceCubit, AdviceState>(
                              builder: (context, state) {
                                return ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                kPrimaryColor),
                                        shape: WidgetStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                          ),
                                        )),
                                    onPressed: () {
                                      context.read<AdviceCubit>().sentAdvice();
                                    },
                                    child: state is SentAdviceLoading
                                        ? const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              color: Color(0xffFFFFFF),
                                            ),
                                          )
                                        : Text(
                                            "إرسال",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600),
                                          ));
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
