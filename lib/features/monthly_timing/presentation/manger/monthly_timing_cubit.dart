import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/data/model/monthly_timing_model.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/data/repos/monthly_timin_repo.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'monthly_timing_state.dart';

class MonthlyTimingCubit extends Cubit<MonthlyTimingState> {
  MonthlyTimingCubit(this.monthlyTimingRepo) : super(MonthlyTimingInitial());
  MonthlyTimingRepo monthlyTimingRepo;
  final TransformationController transformationController =
  TransformationController();
  HijriDate currentHijriDate = HijriDate.now();
  DateTime currentDate = DateTime.now();

  void nextMonth() {
    currentHijriDate = HijriDate.dataToHijri(currentHijriDate.day,
        currentHijriDate.month + 1, currentHijriDate.year);
    currentDate = DateTime(currentDate.day,
        currentDate.month + 1, currentDate.year);

    emit(ChangeMonth());
    getMonthlyTiming(
        year: currentHijriDate.year,
        month: currentHijriDate.month);
  }

  void prevMonth() {
    currentHijriDate = HijriDate.dataToHijri(currentHijriDate.day,
        currentHijriDate.month - 1, currentHijriDate.year);
    currentDate = DateTime(currentDate.day,
        currentDate.month - 1, currentDate.year);

    emit(ChangeMonth());
    getMonthlyTiming(
        year: currentHijriDate.year,
        month: currentHijriDate.month);
  }

  final GlobalKey screenshotKey = GlobalKey();

  Future<void> savePrayerTableAsPdf(MonthlyTimingCubit cubit) async {
    emit(SavePdfLoading());
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final imageData = await rootBundle.load('assets/img/logo2.jpg');
    final imageUint8List = imageData.buffer.asUint8List();
    final image = pw.MemoryImage(imageUint8List);
    final pdf = pw.Document();

    final headers = [
      'العشاء',
      'المغرب',
      'العصر 2',
      'العصر 1',
      'الظهر',
      'الشروق',
      'الفجر',
      'ميلادي',
      'هجري',
      'يوم',
    ];

    final data = cubit.monthlyTimingModel.data;

    try {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a3,
          build: (pw.Context context) {
            return pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child:
                pw.Column(
                    children: [
                      pw.Row(
                          children: [
                            pw.Text(
                              'جدول الصلوات لشهر ${cubit.currentHijriDate
                                  .monthName} ${cubit.currentHijriDate.year}',
                              style: pw.TextStyle(
                                font: ttf,
                                  fontSize: 20, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Spacer(),
                            pw.Text(
                              "ميلادي: ${currentDate
                                  .month} ${currentDate.year}",
                           style:pw.TextStyle(
                             font: ttf,
                             fontSize: 12,
                           ) )
                          ]
                      ),
                      pw.Stack(
                        alignment: pw.Alignment.center,
                        children: [
                          pw.Table.fromTextArray(
                            headers: headers,
                            defaultColumnWidth: pw.FixedColumnWidth(18),
                            headerAlignment: pw.Alignment.center,
                            data: List.generate(data.length, (index) {
                              final row = data[index].timings;
                              return [
                                row.Isha,
                                row.Maghrib,
                                row.Asr_1xShadow,
                                row.Asr,
                                row.Dhuhr,
                                row.Sunrise,
                                row.Fajr,
                                "${currentDate.add(Duration(days: index)).month}/${currentDate.add(Duration(days: index)).day}",
                                index+1,
                                "${days[data[index].day]}",
                              ];
                            }),
                            cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
                            headerStyle: pw.TextStyle(
                                font: ttf,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold),
                            headerDecoration:
                            pw.BoxDecoration(color: PdfColors.grey300),
                            cellAlignment: pw.Alignment.center,
                            columnWidths: {
                              0: const pw.FixedColumnWidth(30),
                            },
                          ),
                          pw.Opacity(
                            opacity: 0.35,
                            child: pw.Image(
                              image,
                              width: 350.w,
                              height: 350.h,
                            ),
                          )
                        ],
                      ),
                    ]
                )
            );
          },
        ),
      );

      // 6. تحديد مسار مجلد التنزيلات
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final file = File(
          '${downloadsDir.path}/أوقات صلاة شهر ${currentHijriDate.monthName +
              Random().nextInt(100).toString()}.pdf');

      // 7. حفظ الملف
      await file.writeAsBytes(await pdf.save());
      emit(SavePdfSuccess(message: 'PDF تم حفظه في: ${file.path}'));
    } catch (e) {
      print(e);
      emit(SavePdfFailure(error: "حدث خطأ ما! اعد المحاولة"));
    }
  }

  MonthlyTimingModel monthlyTimingModel =
  MonthlyTimingModel(success: true, message: '', data: []);

  Future<void> getMonthlyTiming({required int year, required int month}) async {
    emit(GetMonthlyTimingLoading());
    print(year.toString() + 'month: ' + month.toString());
    var result = await monthlyTimingRepo.getMonthlyTiming(
        year: year, month: month, lat: latitude, long: longitude);
    result.fold((fail) {
      emit(GetMonthlyTimingFailure(error: fail.errMessage));
    }, (response) async {
      if (response.data['success'] == false) {
        if (response.data['message'].contains("Validation")) {
          var result = await monthlyTimingRepo.getMonthlyTiming(
              year: year, month: month, lat: 59.913263, long: 10.739122);
          result.fold(
                  (failure) =>
                  emit(
                      GetMonthlyTimingFailure(
                          error: "حدث خطأ ما! اعد المحاولة")),
                  (response) {
                if (response.data['success'] == false) {
                  emit(GetMonthlyTimingFailure(
                      error: "حدث خطأ ما، حاول مجدداً"));
                  return;
                }
                monthlyTimingModel = MonthlyTimingModel.fromJson(response.data);
                emit(GetMonthlyTimingSuccess());
              });
          return;
        }
        emit(GetMonthlyTimingFailure(error: response.data['message']));
        return;
      }
      monthlyTimingModel = MonthlyTimingModel.fromJson(response.data);
      emit(GetMonthlyTimingSuccess());
    });
  }
}
