import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/presentation/view/widgets/custom_column_label.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/presentation/view/widgets/custom_row_label.dart';

import '../../../../core/util/constant.dart';
import '../manger/monthly_timing_cubit.dart';

class MonthPrayTimingTable extends StatefulWidget {
  const MonthPrayTimingTable({
    super.key,
    required this.monthlyTimingCubit,
  });

  final MonthlyTimingCubit monthlyTimingCubit;

  @override
  State<MonthPrayTimingTable> createState() => _MonthPrayTimingTableState();
}

class _MonthPrayTimingTableState extends State<MonthPrayTimingTable> {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      dividerThickness: 0.0,
      headingRowColor: WidgetStateProperty.all(kGreyColor),
      columnSpacing: 8.w,
      columns: [
        DataColumn(label: CustomColumnLabelText(title: "يوم")),
        DataColumn(label: CustomColumnLabelText(title: "الفجر")),
        DataColumn(label: CustomColumnLabelText(title: "الشروق")),
        DataColumn(label: CustomColumnLabelText(title: "الظهر")),
        DataColumn(label: CustomColumnLabelText(title: "العصر 1")),
        DataColumn(label: CustomColumnLabelText(title: "العصر 2")),
        DataColumn(label: CustomColumnLabelText(title: "المغرب")),
        DataColumn(label: CustomColumnLabelText(title: "العشاء")),
      ],
      rows: List.generate(
        widget.monthlyTimingCubit.monthlyTimingModel.data.length,
        (index) {
          return DataRow(cells: [
            DataCell(CustomRowLabel(
                timing: widget
                    .monthlyTimingCubit.monthlyTimingModel.data[index].day)),
            DataCell(CustomRowLabel(
                timing: widget.monthlyTimingCubit.monthlyTimingModel.data[index]
                    .timings.Fajr)),
            DataCell(CustomRowLabel(
                timing: widget.monthlyTimingCubit.monthlyTimingModel.data[index]
                    .timings.Sunrise)),
            DataCell(CustomRowLabel(
                timing: widget.monthlyTimingCubit.monthlyTimingModel.data[index]
                    .timings.Dhuhr)),
            DataCell(CustomRowLabel(
                timing: widget.monthlyTimingCubit.monthlyTimingModel.data[index]
                    .timings.Asr)),
            DataCell(CustomRowLabel(
                timing: widget.monthlyTimingCubit.monthlyTimingModel.data[index]
                    .timings.Asr)),
            DataCell(CustomRowLabel(
                timing: widget.monthlyTimingCubit.monthlyTimingModel.data[index]
                    .timings.Maghrib)),
            DataCell(CustomRowLabel(
                timing: widget.monthlyTimingCubit.monthlyTimingModel.data[index]
                    .timings.Isha)),
          ]);
        },
      ),
    );
  }
}
