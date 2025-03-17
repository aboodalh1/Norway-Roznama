import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/presentation/manger/prays_settings_cubit.dart';

import '../../../../../../core/util/constant.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';
import 'fareeda_reader_dialog.dart';
import 'fareeda_slider_dialog.dart';

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
                  widget.praysCubit.stringPraysTimes[widget.index],
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
                trailing: Switch(
                  activeTrackColor: kPinkColor,
                  value: prayList[widget.index].isNotify,
                  onChanged: (value) {
                    widget.praysCubit.updateFaredaNotify(value, widget.index);
                  },
                ),
              ),
              IconButton(
                  onPressed: () {
                    widget.praysSettingsCubit.faredaExpandationValue[widget.index]
                        ? widget.praysSettingsCubit.collapseFareda()
                        : widget.praysSettingsCubit.expandFareda(widget.index);
                  },
                  icon: Icon(
                      widget.praysSettingsCubit.faredaExpandationValue[widget.index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down))
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: widget.praysSettingsCubit.faredaExpandationValue[widget.index]
                ? 115.h
                : 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              color: const Color(0xffEEEEEE),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      widget.praysSettingsCubit.getAdhan();
                      showDialog(
                        barrierDismissible: false,
                          context: context,
                          builder: (context) {
                          widget.praysSettingsCubit.faredaReader = prayList[widget.index].reader;
                            return FareedaReaderDialog(
                              widget: widget,
                              praysSettingsCubit: widget.praysSettingsCubit,
                            );
                          });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: Row(
                        children: [
                          Text(
                            "صوت المنبه",
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            prayList[widget.index].reader,
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 24.w,
                          ),
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
                    height: 25.h,
                    thickness: 0.5.sp,
                    color: const Color(0xff889CB8),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return FareedaSliderDialog(widget: widget);
                          });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: Row(
                        children: [
                          Text(
                            "منبه الإقامة",
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            '${prayList[widget.index].time.toInt()} دقيقة',
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 24.w,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20.sp,
                            color: const Color(0xff535763),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

