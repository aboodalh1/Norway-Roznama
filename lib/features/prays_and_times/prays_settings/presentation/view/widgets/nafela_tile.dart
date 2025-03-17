import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/presentation/view/widgets/reader_choose_dialog.dart';

import '../../../../../../core/util/constant.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';

class NafelaTile extends StatefulWidget {
  NafelaTile({
    super.key,
    required this.reader,
    required this.switchValue, required this.index,
  });

  String reader;
  bool switchValue;
  final int index;
  @override
  State<NafelaTile> createState() => _NafelaTileState();
}

class _NafelaTileState extends State<NafelaTile> {

  List<String> nawafilName=[
    "الجمعة",
    "الضحى",
    "قيام الليل",
    "التهجد",
    "الأوّابين",
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PraysCubit, PraysState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0.h),
            child: GestureDetector(
              onTap: () {
                showTimePicker(context: context, initialTime: TimeOfDay.now());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffC0C0C0), width: 1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Switch(
                              activeTrackColor: kPinkColor,
                              value: widget.switchValue,
                              onChanged: (value) {
                                setState(() {
                                  widget.switchValue = value;
                                });
                              }),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Text(
                              nawafilName[widget.index],
                              style: TextStyle(
                                  color: const Color(0xff3D3D3D),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "5:45",
                              style: TextStyle(
                                  color: const Color(0xff3D3D3D),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18.h,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const ReaderChooseDialog();
                            });
                      },
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            Text(
                              "صوت المنبه",
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              context.read<PraysCubit>().lastReader,
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
                    )
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