import 'package:flutter/material.dart';

import '../../manger/monthly_timing_cubit.dart';


class SavePdfButton extends StatelessWidget {
  const SavePdfButton({
    super.key, required this.monthlyTimingCubit,
  });
  final MonthlyTimingCubit monthlyTimingCubit;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save_alt, color: Colors.white),
      onPressed: () async{
        await monthlyTimingCubit.savePrayerTableAsPdf(monthlyTimingCubit);
      },
    );
  }
}
