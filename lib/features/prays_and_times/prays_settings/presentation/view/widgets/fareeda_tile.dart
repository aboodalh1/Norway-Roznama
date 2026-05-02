import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/widgets/custom_switch.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/prayer_reminder_config.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/presentation/manger/prays_settings_cubit.dart';

import '../../../../../../core/util/Is24Format.dart';
import '../../../../../../core/util/constant.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';
import 'fareeda_reader_dialog.dart';
import 'fareeda_slider_dialog.dart';
import 'reminder_slot_tile.dart';

class FaredaTile extends StatefulWidget {
  const FaredaTile({
    super.key,
    required this.praysCubit,
    required this.index,
    required this.praysSettingsCubit,
  });

  final PraysSettingsCubit praysSettingsCubit;
  final PraysCubit praysCubit;
  final int index;

  @override
  State<FaredaTile> createState() => _FaredaTileState();
}

class _FaredaTileState extends State<FaredaTile> {
  @override
  void initState() {
    super.initState();
    if (CacheHelper.getData(key: "fareeda_resides${widget.index}") != null) {
      prayList[widget.index].time =
          CacheHelper.getData(key: "fareeda_resides${widget.index}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListTile(
                tileColor: null,
                subtitle: Text(
                  Is24Format.is24TimeFormat?
                  widget.praysCubit.stringPraysTimes24Format[widget.index]:
                  widget.praysCubit.stringPraysTimes12Format[widget.index],
                  style: TextStyle(
                      color: const Color(0xff3D3D3D),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600),
                ),
                title: Text(
                  widget.praysCubit.praysName[widget.index],
                  style: TextStyle(
                      color: const Color(0xff3D3D3D),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600),
                ),
                trailing: CustomSwitch(
                  switchValue: prayList[widget.index].isNotify,
                  function: (value) {
                    widget.praysCubit.updateFaredaNotify(value, widget.index);
                  },
                )
              ),
              IconButton(
                  onPressed: () {
                    widget.praysSettingsCubit
                            .faredaExpandationValue[widget.index]
                        ? widget.praysSettingsCubit.collapseFareda()
                        : widget.praysSettingsCubit.expandFareda(widget.index);
                  },
                  icon: Icon(widget.praysSettingsCubit
                          .faredaExpandationValue[widget.index]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down))
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              color: const Color(0xffEEEEEE),
              child: Column(
                children: [
                  // --- Sound picker row ---
                  InkWell(
                    onTap: () {
                      widget.praysSettingsCubit.getAdhan();
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            widget.praysSettingsCubit.faredaReader =
                                prayList[widget.index].reader;
                            return FareedaReaderDialog(
                              widget: widget,
                              praysSettingsCubit: widget.praysSettingsCubit,
                            );
                          });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Text(
                            "صوت المنبه",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            prayList[widget.index].reader,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 24.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20.sp,
                            color: const Color(0xff535763),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.h,
                    thickness: 0.5.sp,
                    color: const Color(0xff889CB8),
                  ),

                  // --- Iqama row ---
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return FareedaSliderDialog(widget: widget);
                          });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Text(
                            "منبه الإقامة",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            '${prayList[widget.index].time.toInt()} دقيقة',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 24.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20.sp,
                            color: const Color(0xff535763),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.h,
                    thickness: 0.5.sp,
                    color: const Color(0xff889CB8),
                  ),

                  // --- Sub-reminders section ---
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_outlined,
                            size: 16.sp,
                            color: const Color(0xff535763)),
                        SizedBox(width: 6.w),
                        Text(
                          'تذكيرات الأذان',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff535763),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Before-adhan reminder slot
                  ReminderSlotTile(
                    label: 'قبل الأذان',
                    slot: widget.praysCubit
                        .getReminderConfig(widget.index)
                        .before,
                    onSlotChanged: (newSlot) {
                      widget.praysCubit.updateReminderSlot(
                        prayerIndex: widget.index,
                        type: ReminderType.before,
                        newSlot: newSlot,
                      );
                    },
                  ),

                  Divider(
                    height: 1.h,
                    thickness: 0.5.sp,
                    indent: 20.w,
                    endIndent: 20.w,
                    color: const Color(0xffCCCCCC),
                  ),

                  // After-adhan reminder slot
                  ReminderSlotTile(
                    label: 'بعد الأذان',
                    slot: widget.praysCubit
                        .getReminderConfig(widget.index)
                        .after,
                    onSlotChanged: (newSlot) {
                      widget.praysCubit.updateReminderSlot(
                        prayerIndex: widget.index,
                        type: ReminderType.after,
                        newSlot: newSlot,
                      );
                    },
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            crossFadeState:
                widget.praysSettingsCubit.faredaExpandationValue[widget.index]
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}
