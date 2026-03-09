import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/widgets/custom_switch.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';

/// Dedicated tile for Imsak alert, shown above Fajr in the prayer settings.
/// Displays title, helper subtitle, computed time, and independent toggle.
class ImsakTile extends StatelessWidget {
  const ImsakTile({
    super.key,
    required this.praysCubit,
  });

  final PraysCubit praysCubit;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        tileColor: null,
        title: Text(
          'الإمساك',
          style: TextStyle(
            color: const Color(0xff3D3D3D),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              praysCubit.getImsakTimeFormatted(),
              style: TextStyle(
                color: const Color(0xff3D3D3D),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'تنبيه تلقائي قبل 10 دقائق من أذان الفجر',
              style: TextStyle(
                color: const Color(0xff7F7F7F),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: CustomSwitch(
          switchValue: praysCubit.isImsakAlertEnabled,
          function: (value) {
            praysCubit.updateImsakNotify(value);
          },
        ),
      ),
    );
  }
}
