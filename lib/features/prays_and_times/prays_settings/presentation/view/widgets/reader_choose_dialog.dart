import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/util/constant.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';

class ReaderChooseDialog extends StatelessWidget {
  const ReaderChooseDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "الغاء",
                style: TextStyle(fontSize: 12.sp, color: Colors.blueAccent),
              )),
          TextButton(
              onPressed: () {
                context.read<PraysCubit>().confirmReader();
                Navigator.of(context).pop();
              },
              child: Text(
                "موافق",
                style: TextStyle(fontSize: 12.sp, color: Colors.blueAccent),
              )),
        ],
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        surfaceTintColor: Colors.white,
        content: Container(
          decoration: const BoxDecoration(color: Colors.white),
          width: 264.w,
          height: 346.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    "صوت المؤذن",
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ],
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
                      return BlocConsumer<PraysCubit, PraysState>(
                        listener: (context, state) {},
                        builder: (context, state) {
                          return SizedBox(
                            height: 58.h,
                            child: RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                // Adjust padding
                                controlAffinity:
                                ListTileControlAffinity.platform,
                                // Ensure checkbox is on the left
                                activeColor: kPinkColor,
                                title: Text(
                                  textAlign: TextAlign.right,
                                  context.read<PraysCubit>().readers[index],
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                value:
                                context.read<PraysCubit>().readers[index],
                                groupValue: context.read<PraysCubit>().reader,
                                onChanged: (value) {
                                  context
                                      .read<PraysCubit>()
                                      .changeReader(value!);
                                }),
                          );
                        },
                      );
                    },
                    itemCount: 5),
              )
            ],
          ),
        ));
  }
}