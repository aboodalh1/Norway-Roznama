import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:norway_roznama_new_project/core/util/functions.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/presentation/view/widgets/internet_check_widget.dart';
import '../../../../../core/util/constant.dart';
import '../../../../monthly_timing/presentation/manger/monthly_timing_cubit.dart';
import '../../../../monthly_timing/presentation/view/monthly_timing_page.dart';
import '../manger/prays_settings_cubit.dart';
import 'widgets/nawafel_list.dart';
import 'widgets/prayers_big_clock.dart';
import 'widgets/prayers_time_menu.dart';
import '../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';
import 'package:norway_roznama_new_project/core/audio/adhan_audio_handler.dart';
import 'package:norway_roznama_new_project/notification_service.dart';

class PraysSettings extends StatelessWidget {
  const PraysSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PraysSettingsCubit, PraysSettingsState>(
      listener: (context, state) {},
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
                    ? InternetCheckWidget(
                        onTap: () {
                          praysCubit.getPrays();
                        },
                        text: "تأكد من اتصالك بالانترنت ثم حاول مرة اخرى",
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0.w, vertical: 30.h),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // قسم التجريب والاختبار
                              // Container(
                              //   padding: EdgeInsets.symmetric(
                              //       horizontal: 16.w, vertical: 12.h),
                              //   margin: EdgeInsets.only(bottom: 20.h),
                              //   decoration: BoxDecoration(
                              //     color: Colors.blue.withOpacity(0.1),
                              //     border: Border.all(
                              //         color: Colors.blue, width: 1.5),
                              //     borderRadius: BorderRadius.circular(10.r),
                              //   ),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Row(
                              //         children: [
                              //           Icon(Icons.bug_report,
                              //               color: Colors.blue, size: 20.sp),
                              //           SizedBox(width: 8.w),
                              //           Text(
                              //             "أدوات التجريب والاختبار",
                              //             style: TextStyle(
                              //               fontSize: 15.sp,
                              //               fontWeight: FontWeight.bold,
                              //               color: Colors.blue,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(height: 12.h),
                              //       // زر التحقق من الصلاحيات
                              //       _buildTestButton(
                              //         context: context,
                              //         icon: Icons.security,
                              //         title: "التحقق من الصلاحيات",
                              //         subtitle: "تحقق من حالة جميع الصلاحيات",
                              //         onTap: () async {
                              //           final hasPermissions =
                              //               await checkNotificationPermissions();
                              //           showDialog(
                              //             context: context,
                              //             builder: (context) => AlertDialog(
                              //               title: Text("حالة الصلاحيات",
                              //                   style:
                              //                       TextStyle(fontSize: 18.sp)),
                              //               content: Text(
                              //                 hasPermissions
                              //                     ? "✅ جميع الصلاحيات متاحة\n\n- صلاحية الإشعارات: متاحة\n- صلاحية الجدولة الدقيقة: متاحة"
                              //                     : "❌ بعض الصلاحيات غير متاحة\n\nيرجى السماح بالصلاحيات من إعدادات التطبيق",
                              //                 style: TextStyle(fontSize: 14.sp),
                              //               ),
                              //               actions: [
                              //                 TextButton(
                              //                   onPressed: () =>
                              //                       Navigator.pop(context),
                              //                   child: Text("حسناً"),
                              //                 ),
                              //                 if (!hasPermissions)
                              //                   TextButton(
                              //                     onPressed: () async {
                              //                       Navigator.pop(context);
                              //                       final granted =
                              //                           await requestPermissions();
                              //                       if (context.mounted) {
                              //                         ScaffoldMessenger.of(
                              //                                 context)
                              //                             .showSnackBar(
                              //                           SnackBar(
                              //                             content: Text(granted
                              //                                 ? "✅ تم منح الصلاحيات بنجاح"
                              //                                 : "⚠️ يرجى السماح بالصلاحيات من إعدادات الجهاز"),
                              //                           ),
                              //                         );
                              //                       }
                              //                     },
                              //                     child: Text("طلب الصلاحيات"),
                              //                   ),
                              //               ],
                              //             ),
                              //           );
                              //         },
                              //       ),
                              //       SizedBox(height: 8.h),
                              //       // زر إعادة جدولة جميع الإشعارات
                              //       _buildTestButton(
                              //         context: context,
                              //         icon: Icons.schedule,
                              //         title: "إعادة جدولة جميع الإشعارات",
                              //         subtitle: "إلغاء القديم وجدولة جديدة",
                              //         onTap: () async {
                              //           showDialog(
                              //             context: context,
                              //             barrierDismissible: false,
                              //             builder: (context) => AlertDialog(
                              //               content: Row(
                              //                 children: [
                              //                   CircularProgressIndicator(),
                              //                   SizedBox(width: 16.w),
                              //                   Expanded(
                              //                       child: Text(
                              //                           "جاري إعادة الجدولة...",
                              //                           style: TextStyle(
                              //                               fontSize: 14.sp))),
                              //                 ],
                              //               ),
                              //             ),
                              //
                              // );
                              //           try {
                              //             await praysCubit
                              //                 .rescheduleAllPrayerNotifications();
                              //             if (context.mounted) {
                              //               Navigator.pop(context);
                              //               ScaffoldMessenger.of(context)
                              //                   .showSnackBar(
                              //                 SnackBar(
                              //                   content: Text(
                              //                       "✅ تمت إعادة جدولة جميع الإشعارات بنجاح"),
                              //                   backgroundColor: Colors.green,
                              //                   duration: Duration(seconds: 3),
                              //                 ),
                              //               );
                              //             }
                              //           } catch (e) {
                              //             if (context.mounted) {
                              //               Navigator.pop(context);
                              //               ScaffoldMessenger.of(context)
                              //                   .showSnackBar(
                              //                 SnackBar(
                              //                   content: Text("❌ خطأ: $e"),
                              //                   backgroundColor: Colors.red,
                              //                   duration: Duration(seconds: 4),
                              //                 ),
                              //               );
                              //             }
                              //           }
                              //         },
                              //       ),
                              //       SizedBox(height: 8.h),
                              //       // زر اختبار الأذان مباشرة
                              //       _buildTestButton(
                              //         context: context,
                              //         icon: Icons.play_arrow,
                              //         title: "اختبار الأذان",
                              //         subtitle: "تشغيل الأذان الآن",
                              //         onTap: () async {
                              //           showDialog(
                              //             context: context,
                              //             barrierDismissible: false,
                              //             builder: (context) => AlertDialog(
                              //               content: Row(
                              //                 children: [
                              //                   CircularProgressIndicator(),
                              //                   SizedBox(width: 16.w),
                              //                   Expanded(
                              //                       child: Text(
                              //                           "جاري تشغيل الأذان...",
                              //                           style: TextStyle(
                              //                               fontSize: 14.sp))),
                              //                 ],
                              //               ),
                              //             ),
                              //           );
                              //           try {
                              //             await AdhanAudioController.playAdhan(
                              //               id: 999,
                              //               title: 'اختبار الأذان',
                              //               body: 'اختبار تشغيل الأذان',
                              //               soundPath: 'sounds/alafasi.mp3',
                              //             );
                              //             if (context.mounted) {
                              //               Navigator.pop(context);
                              //               ScaffoldMessenger.of(context)
                              //                   .showSnackBar(
                              //                 SnackBar(
                              //                   content: Text(
                              //                       "✅ تم تشغيل الأذان - اضغط للتوقف"),
                              //                   backgroundColor: Colors.green,
                              //                   duration: Duration(seconds: 2),
                              //                   action: SnackBarAction(
                              //                     label: "إيقاف",
                              //                     textColor: Colors.white,
                              //                     onPressed: () async {
                              //                       await AdhanAudioController
                              //                           .stopAdhan();
                              //                     },
                              //                   ),
                              //                 ),
                              //               );
                              //             }
                              //           } catch (e) {
                              //             if (context.mounted) {
                              //               Navigator.pop(context);
                              //               ScaffoldMessenger.of(context)
                              //                   .showSnackBar(
                              //                 SnackBar(
                              //                   content: Text(
                              //                       "❌ خطأ في تشغيل الأذان: $e"),
                              //                   backgroundColor: Colors.red,
                              //                   duration: Duration(seconds: 4),
                              //                 ),
                              //               );
                              //             }
                              //           }
                              //         },
                              //       ),
                              //       SizedBox(height: 8.h),
                              //       // زر اختبار الإشعار (بعد دقيقة)
                              //       _buildTestButton(
                              //         context: context,
                              //         icon: Icons.notifications_active,
                              //         title: "اختبار الإشعار (دقيقة واحدة)",
                              //         subtitle: "جدولة إشعار تجريبي بعد دقيقة",
                              //         onTap: () async {
                              //           try {
                              //             final now = DateTime.now();
                              //             final testTime =
                              //                 now.add(Duration(minutes: 1));

                              //             LocalNotificationService
                              //                 .showDailySchduledNotification(
                              //               9999, // ID خاص للتجريب
                              //               "اختبار الأذان",
                              //               testTime.hour,
                              //               testTime.minute,
                              //               soundPath: "alafasi",
                              //             );

                              //             if (context.mounted) {
                              //               ScaffoldMessenger.of(context)
                              //                   .showSnackBar(
                              //                 SnackBar(
                              //                   content: Text(
                              //                       "✅ تم جدولة إشعار تجريبي بعد دقيقة واحدة (الساعة ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')})"),
                              //                   backgroundColor: Colors.green,
                              //                   duration: Duration(seconds: 4),
                              //                 ),
                              //               );
                              //             }
                              //           } catch (e) {
                              //             if (context.mounted) {
                              //               ScaffoldMessenger.of(context)
                              //                   .showSnackBar(
                              //                 SnackBar(
                              //                   content: Text("❌ خطأ: $e"),
                              //                   backgroundColor: Colors.red,
                              //                   duration: Duration(seconds: 4),
                              //                 ),
                              //               );
                              //             }
                              //           }
                              //         },
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Row(
                                children: [
                                  Text(
                                    "تفعيل التنبيهات",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<MonthlyTimingCubit>()
                                          .currentHijriDate = HijriDate.now();
                                      navigateTo(context, MonthlyTimingPage());
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(3),
                                      width: 35.w,
                                      height: 34.h,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          border:
                                              Border.all(color: kPrimaryColor)),
                                      child: Text(
                                        "pdf",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12.sp,
                                            color: kPrimaryColor),
                                      ),
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
                              if (!praysCubit.isOslo)
                                SizedBox(
                                  height: 40.h,
                                ),
                              if (praysCubit.isOslo)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 21.0.w, vertical: 10.h),
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
                              if (praysCubit.isOslo)
                                SizedBox(
                                  height: 10.h,
                                ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w, vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xffD9D9D9).withOpacity(0.5),
                                        border: Border.all(
                                            color: Color(0xffC0C0C0), width: 1),
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                      ),
                                      margin: EdgeInsets.only(bottom: 14.h),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "الفرائض",
                                                style: TextStyle(
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              context
                                                      .read<
                                                          PraysSettingsCubit>()
                                                      .isExpand
                                                  ? context
                                                      .read<
                                                          PraysSettingsCubit>()
                                                      .changeExpand(false)
                                                  : context
                                                      .read<
                                                          PraysSettingsCubit>()
                                                      .changeExpand(true);
                                            },
                                            child: Icon(
                                              context
                                                      .read<
                                                          PraysSettingsCubit>()
                                                      .isExpand
                                                  ? Icons
                                                      .keyboard_arrow_up_outlined
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
                                      praysSettingsCubit:
                                          context.read<PraysSettingsCubit>(),
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
              color: const Color(0xff3E73BC), size: 25.sp),
          onPressed: () {
            praysCubit.pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
          },
        ),
        SizedBox(
          height: 240.h,
          width: 240.w,
          child: PageView(
              controller: praysCubit.pageController,
              children: List.generate(
                  context.read<PraysCubit>().praysName.length,
                  (index) => PrayerBigClock(
                        index: index,
                        praysCubit: context.read<PraysCubit>(),
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
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
          },
        ),
      ],
    );
  }
}

Widget _buildTestButton({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: kPrimaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
        ],
      ),
    ),
  );
}
