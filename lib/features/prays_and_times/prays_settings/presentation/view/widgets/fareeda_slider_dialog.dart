import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/util/constant.dart';
import 'fareeda_tile.dart';

class FareedaSliderDialog extends StatelessWidget {
  const FareedaSliderDialog({
    super.key,
    required this.widget,
  });

  final FaredaTile widget;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setStates) => AlertDialog(
        content: SizedBox(
          width: 231.w,
          height: 280.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "منبه الإقامة",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                "..بعد الاذان ب",
                style: TextStyle(
                    color: const Color(0xff535763),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 40.h,
              ),
              Slider(
                  autofocus: true,
                  divisions: 5,
                  max: 30, 
                  min: 5,
                  thumbColor: kGreyColor,
                  activeColor: const Color(0xff3E73BC),
                  value: widget.praysCubit.faredaTime,
                  onChanged: (value) {
                    setStates(() {
                      widget.praysCubit.faredaTime = value;
                    });
                  }),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Row(
                  children: [
                    Text(
                      "5",
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      "10",
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      "15",
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      "20",
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      "25",
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      "30",
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 28.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.0.w),
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "إالغاء",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff3E73BC),
                          ),
                        )),
                    const Spacer(),
                    Container(
                      height: 31.h,
                      width: 1.w,
                      color: const Color(0xff7F7F7F),
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          widget.praysCubit.updateFaredaTime(
                              widget.praysCubit.faredaTime, widget.index);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "موافق",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff3E73BC),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
    );
  }
}