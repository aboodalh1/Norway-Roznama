import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/presentation/manger/prays_settings_cubit.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';
import 'fareeda_tile.dart';

class FareedaSettingsList extends StatelessWidget {
  const FareedaSettingsList({super.key, required this.praysCubit, required this.praysSettingsCubit});
  final PraysSettingsCubit praysSettingsCubit;
  final PraysCubit praysCubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          decoration: BoxDecoration(border: Border.all(color: Color(0xffC0C0C0),),
          borderRadius: BorderRadius.circular(15.r),
            color: Color(0xffC5C5C5).withOpacity(0.3)
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: praysSettingsCubit.isExpand
              ? praysSettingsCubit.isFaredaExpand
                  ? 620
                  : 510
              : 0,
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 7,
              itemBuilder: (context, index) {
                return FaredaTile(
                    praysSettingsCubit: praysSettingsCubit,
                    index: index,
                    praysCubit: praysCubit
                );
              }),
        ),

      ],
    );
  }
}

