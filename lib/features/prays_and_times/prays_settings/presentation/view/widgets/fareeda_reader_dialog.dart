import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/widgets/custom_snack_bar.dart';

import '../../../../../../core/util/constant.dart';

import '../../manger/prays_settings_cubit.dart';

import 'fareeda_tile.dart';

class FareedaReaderDialog extends StatefulWidget {
  const FareedaReaderDialog({
    super.key,
    required this.widget,
    required this.praysSettingsCubit,
  });

  final PraysSettingsCubit praysSettingsCubit;
  final FaredaTile widget;

  @override
  State<FareedaReaderDialog> createState() => _FareedaReaderDialogState();
}

class _FareedaReaderDialogState extends State<FareedaReaderDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PraysSettingsCubit, PraysSettingsState>(
        listener: (context,state){
          if(state is AdhanDownloadFailure){
            customSnackBar(context, state.error,color: Colors.redAccent);
          }
          if(state is AdhanDownloadSuccess){
            customSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
      return  AlertDialog(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                actions: [
                  TextButton(
                      onPressed: () {
                        widget.praysSettingsCubit.faredaReader = widget.praysSettingsCubit.lastReader;
                        for(int i=0;i<widget.praysSettingsCubit.isPlaying.length;i++){
                          widget.praysSettingsCubit.isPlaying[i] = false;
                        }
                        widget.praysSettingsCubit.player.stop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "الغاء",
                        style: TextStyle(fontSize: 12.sp, color: Colors.blueAccent),
                      )),
                  TextButton(
                      onPressed: () {
                        widget.praysSettingsCubit.confirmReader(widget.widget.index);
                        for(int i=0;i<widget.praysSettingsCubit.isPlaying.length;i++){
                          widget.praysSettingsCubit.isPlaying[i] = false;
                        }
                        widget.praysSettingsCubit.player.stop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "موافق",
                        style: TextStyle(fontSize: 12.sp, color: Colors.blueAccent),
                      )),
                ],
                backgroundColor: Colors.white,
                shape:
                    const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
                surfaceTintColor: Colors.white,
                content: state is GetAdhanFailure
                    ? Text(
                        textDirection: TextDirection.rtl,
                        state.error,
                        style: TextStyle(color: Colors.red, fontSize: 15.sp),
                      )
                    : state is GetAdhanLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 40.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(color: Colors.white),
                            width: 264.w,
                            height: 300.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "صوت المؤذن",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                SizedBox(
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return Divider(
                                          height: 0.8.h,
                                          color: const Color(0xff889CB8),
                                        );
                                      },
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          height: 58.h,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 220.w,
                                                child: RadioListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    controlAffinity: ListTileControlAffinity.platform,
                                                    activeColor: kPinkColor,
                                                    title: Text(
                                                      textAlign: TextAlign.right,
                                                      widget.praysSettingsCubit.readers[index],
                                                      style: TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black),
                                                    ),
                                                    value:
                                                    widget.praysSettingsCubit.readers[index],
                                                    groupValue: widget.praysSettingsCubit.faredaReader,
                                                    onChanged: (value) {
                                                        widget.praysSettingsCubit
                                                            .changeReader(value!);
                                                    }),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    if (
                                                        adhanDownloaded[index] ==
                                                        'false') {
                                                      widget.praysSettingsCubit.downloadAdhan(index,
                                                          widget.praysSettingsCubit.adhanModel.data[index].url,
                                                          widget.praysSettingsCubit.adhanModel.data[index]
                                                              .name);
                                                    } else {
                                                        if (widget.praysSettingsCubit.isPlaying[index]) {
                                                          setState(() {
                                                          widget.praysSettingsCubit.isPlaying[index] = false;
                                                          });
                                                          widget.praysSettingsCubit.player.stop();
                                                        } else {
                                                          for(int i=0;i<widget.praysSettingsCubit.isPlaying.length;i++){
                                                            widget.praysSettingsCubit.isPlaying[i] = false;
                                                          }
                                                          setState(() {
                                                          widget.praysSettingsCubit.isPlaying[index] = true;
                                                          });
                                                          widget.praysSettingsCubit.playLocalAdhan(index);
                                                        }
                                                    }
                                                  },
                                                  child: widget.praysSettingsCubit.isDonwloading[index]? SizedBox(
                                                      width:10.w,
                                                      height: 10.h,
                                                      child: CircularProgressIndicator(color: kPinkColor,strokeWidth: 1.2,)):Icon(
                                                    adhanDownloaded[index] ==
                                                        'false'
                                                        ? Icons.save_alt_outlined
                                                        : widget.praysSettingsCubit.isPlaying[index]
                                                        ? Icons.pause_circle_outline
                                                        : Icons.play_arrow_outlined,
                                                    size: 20.sp,
                                                    color: kPinkColor,
                                                  )),
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: 4),
                                ),
                              ],
                            ),
                          )

      );
    });
  }
}


