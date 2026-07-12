import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:norway_roznama_new_project/alarm_helper.dart';
import 'package:norway_roznama_new_project/core/services/reminder_scheduler.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/adhan_sound_mapper.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/prayer_reminder_config.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/reminder_config_repository.dart';
import 'package:norway_roznama_new_project/notification_service.dart';
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/util/constant.dart';
import '../../data/model/prays_model.dart';
import '../../data/repos/prays_repo.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
part 'prays_state.dart';

class PraysCubit extends Cubit<PraysState> {
  PraysCubit(this.prayersRepo) : super(PraysInitial()) {
    _loadReminderConfigs();
    getLocalPraysTimes();
  }

  PraysRepo prayersRepo;

  /// Per-prayer reminder configurations, parallel to [prayList].
  List<PrayerReminderConfig> prayerReminderConfigs = List.generate(
    7,
    (_) => PrayerReminderConfig.defaultConfig,
  );

  void _loadReminderConfigs() {
    prayerReminderConfigs = ReminderConfigRepository.loadAllConfigs();
  }

  /// Checks if the native ReminderSystemEventReceiver set a reconcile flag
  /// (written after reboot / timezone / manual time change).
  /// If so, clears the flag and triggers a full reminder reschedule.
  Future<void> _checkAndHandleSystemEventReconcileFlag() async {
    final bool needsReconcile =
        CacheHelper.getData(key: 'reminder_needs_reconcile') as bool? ?? false;
    if (!needsReconcile) return;

    print(
        '[PraysCubit] System event reconcile flag detected — rescheduling reminders.');
    CacheHelper.saveData(key: 'reminder_needs_reconcile', value: false);
    await _rescheduleAllReminders();
  }

  /// Returns the current [PrayerReminderConfig] for [prayerIndex].
  PrayerReminderConfig getReminderConfig(int prayerIndex) =>
      prayerReminderConfigs[prayerIndex];

  /// Updates a single reminder slot and immediately reschedules for that prayer.
  Future<void> updateReminderSlot({
    required int prayerIndex,
    required ReminderType type,
    required ReminderSlotConfig newSlot,
  }) async {
    final currentConfig = prayerReminderConfigs[prayerIndex];

    // When changing from once → frequent, cancel the pending once instance.
    final oldSlot = type == ReminderType.before
        ? currentConfig.before
        : currentConfig.after;
    if (oldSlot.mode == ReminderMode.once &&
        newSlot.mode == ReminderMode.frequent) {
      await ReminderScheduler.cancelPrayerSlot(prayerIndex, type);
    }

    final updated = type == ReminderType.before
        ? currentConfig.copyWith(before: newSlot)
        : currentConfig.copyWith(after: newSlot);

    prayerReminderConfigs[prayerIndex] = updated;
    ReminderConfigRepository.saveConfig(prayerIndex, updated);

    // Re-schedule when prayer times are loaded. Reminders are independent of
    // the main adhan on/off switch — the slot's own enabled flag gates them.
    if (datePraysTimes.length > prayerIndex) {
      await ReminderScheduler.reschedulePrayerReminders(
        prayerIndex: prayerIndex,
        prayerTime: datePraysTimes[prayerIndex],
        config: updated,
        prayerName: praysName[prayerIndex],
        soundPath: _adhanSoundPathForPrayer(prayerIndex),
      );
    }

    emit(ChangeReminderState());
  }

  List<String> praysName = [
    "الفجر",
    "الشروق",
    "الظهر",
    " العصر الأول",
    "العصر الثاني",
    "المغرب",
    "العشاء",
  ];

  List<String> stringPraysTimes12Format = [
    '00:00',
    '00:00',
    '00:00',
    '00:00',
    '00:00',
    '00:00',
    '00:00'
  ];
  List<String> stringPraysTimes24Format = [
    '00:00',
    '00:00',
    '00:00',
    '00:00',
    '00:00',
    '00:00',
    '00:00'
  ];

  List<DateTime> datePraysTimes = [];

  int neartestPrayIndex = 0;

  String _adhanSoundPathForPrayer(int index) {
    final selectedSoundPath =
        AdhanSoundMapper.getAssetPath(prayList[index].readerId);
    if (selectedSoundPath != null && selectedSoundPath.isNotEmpty) {
      return selectedSoundPath;
    }

    final fallbackSoundPath = AdhanSoundMapper.getAssetPath(1);
    if (fallbackSoundPath != null && fallbackSoundPath.isNotEmpty) {
      print(
          '⚠️ [PraysCubit] Invalid readerId ${prayList[index].readerId} for prayer $index. Falling back to Alafasi.');
      return fallbackSoundPath;
    }

    return 'sounds/alafasi.mp3';
  }

  /// Notification ID for Imsak alert. Must not conflict with prayer IDs (0-6) or iqama (400-406).
  static const int imsakNotificationId = 500;

  /// Imsak is Fajr - 10 minutes.
  static const int imsakMinutesBeforeFajr = 10;

  /// Persistent state for Imsak alert. Disabled by default.
  bool isImsakAlertEnabled = false;

  void convertTo24HourFormat() {
    for (int i = 0; i < stringPraysTimes12Format.length; i++) {
      stringPraysTimes24Format[i] =
          convertTo24Hour(stringPraysTimes12Format[i]);
    }
  }

  String convertTo24Hour(String time) {
    try {
      final DateFormat format12 = DateFormat('hh:mm a');
      final DateFormat format24 = DateFormat('HH:mm');

      final DateTime parsedTime = format12.parse(time);
      return format24.format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  void getLocalPraysTimes() {
    if (CacheHelper.getData(key: "praysTimes") != null) {
      stringPraysTimes12Format = CacheHelper.getData(key: "praysTimes");
      for (int i = 0; i < prayList.length; i++) {
        if (CacheHelper.getData(key: "pray_$i") != null) {
          prayList[i].isNotify = CacheHelper.getData(key: "pray_$i");
        }
      }
      if (CacheHelper.getData(key: 'is_imsak_alert_enabled') != null) {
        isImsakAlertEnabled =
            CacheHelper.getData(key: 'is_imsak_alert_enabled');
      }
      convertTo24HourFormat();

      DateTime now = DateTime.now(); // Get today's date
      datePraysTimes = stringPraysTimes24Format.map((time) {
        List<String> parts = time.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].substring(0, 2));
        return DateTime(now.year, now.month, now.day, hour, minute);
      }).toList();

      // Reschedule notifications after loading local times.
      rescheduleAllPrayerNotifications();

      // Handle system event reconcile flag set by native receiver.
      _checkAndHandleSystemEventReconcileFlag();

      emit(GetLocalPrayersTimesSuccess());
    } else {
      getPrays();
    }
  }

  void assignPrayersTimes() {
    datePraysTimes = [];
    stringPraysTimes12Format[0] = prayersModel.data.timings.Fajr;
    stringPraysTimes12Format[1] = prayersModel.data.timings.Sunrise;
    stringPraysTimes12Format[2] = prayersModel.data.timings.Dhuhr;
    stringPraysTimes12Format[3] = prayersModel.data.timings.Asr;
    stringPraysTimes12Format[4] = prayersModel.data.timings.AsrShadow;
    stringPraysTimes12Format[5] = prayersModel.data.timings.Maghrib;
    stringPraysTimes12Format[6] = prayersModel.data.timings.Isha;

    CacheHelper.saveData(key: 'praysTimes', value: stringPraysTimes12Format);

    convertTo24HourFormat();
    DateTime now = DateTime.now(); // Get today's date
    datePraysTimes = stringPraysTimes24Format.map((time) {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].substring(0, 2));
      return DateTime(now.year, now.month, now.day, hour, minute);
    }).toList();

    // Reschedule notifications after assigning new times
    rescheduleAllPrayerNotifications();
  }

  DateTime? getNearestPrayTime() {
    DateTime now = DateTime.now();
    DateTime? nearestTime;
    bool isFound = false;
    print(datePraysTimes);
    for (int i = 0; i < datePraysTimes.length; i++) {
      print(datePraysTimes[i]);
      print(now);
      if (datePraysTimes[i].isAfter(now)) {
        print("After: ${datePraysTimes[i]}");
        if (nearestTime == null || datePraysTimes[i].isBefore(nearestTime)) {
          print(datePraysTimes[i]);
          nearestTime = datePraysTimes[i];
          neartestPrayIndex = i;
          isFound = true;
        }
      }
    }
    if (!isFound) {
      nearestTime = datePraysTimes[0];
      neartestPrayIndex = 0;
      isFound = true;
    }
    emit(GetPrayersTimesSuccess(message: ''));
    return nearestTime;
  }

  Future<void> saveTodayPrayerTimesAsPdf() async {
    if (datePraysTimes.length < 7 ||
        stringPraysTimes12Format.length < 7 ||
        stringPraysTimes24Format.length < 7) {
      emit(SavePrayerTimesPdfFailureState(
          error: "أوقات الصلاة غير مكتملة، حاول تحديث الأوقات أولاً"));
      return;
    }

    emit(SavePrayerTimesPdfLoadingState());

    try {
      final now = DateTime.now();
      final dateText = DateFormat('yyyy-MM-dd').format(now);
      final dayText = days[DateFormat('E').format(now)] ?? '';
      final hijriDate = prayersModel.data.hijriDate.trim();
      final shownTimes = Is24Format.is24TimeFormat
          ? stringPraysTimes24Format
          : stringPraysTimes12Format;

      final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
      final arabicFont = pw.Font.ttf(fontData);
      final logoData = await rootBundle.load('assets/img/logo2.jpg');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      final pdf = pw.Document();

      pw.Widget metaChip(String text) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#EDF7EE'),
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColor.fromHex('#CDE8D0')),
          ),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 12,
              color: PdfColor.fromHex('#285A2A'),
            ),
          ),
        );
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Stack(
                children: [
                  pw.Positioned.fill(
                    child: pw.Center(
                      child: pw.Opacity(
                        opacity: 0.08,
                        child: pw.Image(logoImage, width: 300, height: 300),
                      ),
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(18),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#057107'),
                          borderRadius: pw.BorderRadius.circular(18),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 58,
                              height: 58,
                              padding: const pw.EdgeInsets.all(6),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(14),
                              ),
                              child:
                                  pw.Image(logoImage, fit: pw.BoxFit.contain),
                            ),
                            pw.SizedBox(width: 14),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'أوقات الصلاة',
                                    style: pw.TextStyle(
                                      font: arabicFont,
                                      fontSize: 28,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    'جدول أوقات الصلاة لهذا اليوم',
                                    style: pw.TextStyle(
                                      font: arabicFont,
                                      fontSize: 13,
                                      color: PdfColor.fromHex('#EAF7EA'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 18),
                      pw.Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (dayText.isNotEmpty) metaChip('اليوم: $dayText'),
                          metaChip('التاريخ الميلادي: $dateText'),
                          if (hijriDate.isNotEmpty)
                            metaChip('التاريخ الهجري: $hijriDate'),
                        ],
                      ),
                      if (isOslo) ...[
                        pw.SizedBox(height: 12),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#FFF4E5'),
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(
                              color: PdfColor.fromHex('#F2C27B'),
                            ),
                          ),
                          child: pw.Text(
                            'تنبيه: أوقات الصلاة بتوقيت مدينة أوسلو، النرويج',
                            style: pw.TextStyle(
                              font: arabicFont,
                              fontSize: 13,
                              color: PdfColor.fromHex('#8A4F00'),
                            ),
                          ),
                        ),
                      ],
                      pw.SizedBox(height: 18),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(16),
                          border:
                              pw.Border.all(color: PdfColor.fromHex('#DADADA')),
                        ),
                        child: pw.Table(
                          border: pw.TableBorder.symmetric(
                            inside: pw.BorderSide(
                              color: PdfColor.fromHex('#E6E6E6'),
                              width: 0.8,
                            ),
                          ),
                          columnWidths: const {
                            0: pw.FlexColumnWidth(2),
                            1: pw.FlexColumnWidth(3),
                          },
                          children: [
                            pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#EDF7EE'),
                                borderRadius: const pw.BorderRadius.only(
                                  topLeft: pw.Radius.circular(16),
                                  topRight: pw.Radius.circular(16),
                                ),
                              ),
                              children: [
                                _pdfCell('الوقت', arabicFont, isHeader: true),
                                _pdfCell('الصلاة', arabicFont, isHeader: true),
                              ],
                            ),
                            ...List.generate(praysName.length, (index) {
                              return pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: index.isEven
                                      ? PdfColors.white
                                      : PdfColor.fromHex('#FAFAFA'),
                                ),
                                children: [
                                  _pdfCell(shownTimes[index], arabicFont),
                                  _pdfCell(praysName[index].trim(), arabicFont),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      pw.Spacer(),
                      pw.Divider(color: PdfColor.fromHex('#DADADA')),
                      pw.Text(
                        'تم إنشاء الملف من تطبيق Norway Roznama',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 11,
                          color: PdfColor.fromHex('#666666'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }
      final file = File('${downloadsDir.path}/أوقات الصلاة $dateText.pdf');
      await file.writeAsBytes(await pdf.save());
      emit(SavePrayerTimesPdfSuccessState(message: 'تم حفظ PDF في: ${file.path}'));
    } catch (e) {
      print(e);
      emit(SavePrayerTimesPdfFailureState(error: "حدث خطأ ما! أعد المحاولة"));
    }
  }

  pw.Widget _pdfCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 15 : 14,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader
              ? PdfColor.fromHex('#285A2A')
              : PdfColor.fromHex('#222222'),
        ),
      ),
    );
  }

  PrayersModel prayersModel = PrayersModel(
    success: true,
    message: "message",
    data: Data(
      timings: Timings(
        Fajr: 'Fajr',
        Sunrise: 'Sunrise',
        Dhuhr: 'Dhuhr',
        Asr: 'Asr',
        AsrShadow: '',
        Maghrib: 'Maghrib',
        Isha: 'Isha',
      ),
      date: '',
      hijriDate: '',
    ),
  );

  bool isOslo = false;

  Future<void> getPrays() async {
    if (latitude == 0.0 || longitude == 0.0) {
      emit(LocationMissedState(message: "من فضلك قم بتحديد موقعك"));
      return;
    }
    emit(GetPraysTimesLoading());
    var result =
        await prayersRepo.getPrayersTimes(lat: latitude, long: longitude);
    result.fold(
      (l) async {
        var result =
            await prayersRepo.getPrayersTimes(lat: 59.913263, long: 10.739122);
        result.fold(
          (failure) =>
              emit(GetPrayersTimesError(error: "حدث خطأ ما! اعد المحاولة")),
          (response) {
            if (response.data['success'] == false) {
              print(response.data);
              emit(GetPrayersTimesError(error: "حدث خطأ ما، حاول مجدداً"));
              return;
            }
            prayersModel = PrayersModel.fromJson(response.data);
            assignPrayersTimes();
            isOslo = true;
            emit(GetPrayersTimesSuccess(message: "message"));
          },
        );
      },
      (response) async {
        print(response.data);
        if (response.data['success'] == false) {
          if (response.data['message'].contains("Validation")) {
            var result = await prayersRepo.getPrayersTimes(
                lat: 59.913263, long: 10.739122);
            result.fold(
              (failure) =>
                  emit(GetPrayersTimesError(error: "حدث خطأ ما! اعد المحاولة")),
              (response) {
                if (response.data['success'] == false) {
                  emit(GetPrayersTimesError(error: "حدث خطأ ما، حاول مجدداً"));
                  return;
                }
                prayersModel = PrayersModel.fromJson(response.data);
                assignPrayersTimes();
                isOslo = true;
                emit(GetPrayersTimesSuccess(message: "message"));
              },
            );
            return;
          }
          emit(GetPrayersTimesError(error: response.data['message']));
          return;
        }
        try {
          prayersModel = PrayersModel.fromJson(response.data);
          assignPrayersTimes();
          isOslo = false;
          emit(GetPrayersTimesSuccess(message: prayersModel.message));
        } catch (e) {
          emit(GetPrayersTimesError(error: e.toString()));
        }
      },
    );
  }

  String reader = 'مشاري العفاسي';
  String lastReader = 'مشاري العفاسي';

  List<String> readers = [
    "مشاري العفاسي",
    "ياسر الدوسري",
    "الحصري",
    "عبدالباسط عبدالصمد",
    "صوت الاشعار الافتراضي",
  ];

  void changeReader(String value) {
    reader = value;
    emit(ChangeReaderState());
  }

  void confirmReader() {
    lastReader = reader;
    emit(ChangeReaderState());
  }

  void updateFaredaNotify(bool value, int index) async {
    prayList[index].isNotify = value;
    if (!value) {
      // Cancel both local notification and native adhan alarm
      LocalNotificationService.cancelNotification(index);
      await AlarmHelper.cancelPrayerAlarm(index);
      // Cancel sub-reminders for this prayer.
      await ReminderScheduler.cancelPrayerReminders(index);
      CacheHelper.saveData(key: 'pray_$index', value: value);
    }
    if (value) {
      var hasPermissions = await checkNotificationPermissions();
      if (!hasPermissions) {
        hasPermissions = await requestPermissions();
      }
      if (!hasPermissions) {
        print(
            '❌ [PraysCubit] Permissions denied. Cannot schedule ${praysName[index]} adhan.');
        prayList[index].isNotify = false;
        CacheHelper.saveData(key: 'pray_$index', value: false);
        emit(ChangeFaredaState());
        return;
      }

      final soundPath = _adhanSoundPathForPrayer(index);
      tz.initializeTimeZones();
      String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      var currentTime = tz.TZDateTime.now(tz.local);

      var scheduleTime = tz.TZDateTime(
          tz.local,
          currentTime.year,
          currentTime.month,
          currentTime.day,
          datePraysTimes[index].hour,
          datePraysTimes[index].minute);

      // If the scheduled time is in the past, schedule for the next day.
      if (scheduleTime.isBefore(currentTime)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      print(soundPath);
      final scheduled = await AlarmHelper.setPrayerAlarm(
        id: index,
        prayerName: praysName[index],
        prayerTime: scheduleTime,
        customSoundPath: soundPath,
      );

      if (scheduled) {
        print(
            '✅ [PraysCubit] Scheduled Adhan for ${praysName[index]} at $scheduleTime');
      } else {
        prayList[index].isNotify = false;
        CacheHelper.saveData(key: 'pray_$index', value: false);
        emit(ChangeFaredaState());
        return;
      }

      // LocalNotificationService.showDailySchduledNotification(
      //   index,
      //   praysName[index],
      //   soundPath: soundPath, // Extract the file name without extension
      //   datePraysTimes[index].hour,
      //   datePraysTimes[index].minute,
      // );

      // await AlarmHelper.setCustomAlarm(hour: datePraysTimes[index].hour,minute: datePraysTimes[index].minute, title: 'Salat', message: "Salat Duhr");
      LocalNotificationService.showDailySchduledNotification(
        index + 400,
        "إقامة ${praysName[index]}",
        soundPath: soundPath, // Extract the file name without extension
        datePraysTimes[index]
            .add(Duration(minutes: prayList[index].time.toInt()))
            .hour,
        datePraysTimes[index]
            .add(Duration(minutes: prayList[index].time.toInt()))
            .minute,
      );
      CacheHelper.saveData(key: 'pray_$index', value: value);

      // Schedule sub-reminders for this prayer via WorkManager.
      await ReminderScheduler.reschedulePrayerReminders(
        prayerIndex: index,
        prayerTime: scheduleTime.toLocal(),
        config: prayerReminderConfigs[index],
        prayerName: praysName[index],
        soundPath: soundPath,
      );
    }
    emit(ChangeFaredaState());
  }

  /// Re-schedule a prayer alarm when the reader/sound is changed.
  ///
  /// This cancels the existing alarm and schedules a new one with the updated sound path.
  Future<void> reschedulePrayerAlarm(int index) async {
    if (!prayList[index].isNotify) {
      // Notification not enabled, nothing to re-schedule
      return;
    }

    print(
        '🔄 [PraysCubit] Re-scheduling alarm for prayer $index with readerId: ${prayList[index].readerId}');

    // Cancel the existing alarm first
    await AlarmHelper.cancelPrayerAlarm(index);

    // Get the new sound path based on readerId using AdhanSoundMapper
    final soundPath = _adhanSoundPathForPrayer(index);

    try {
      // Calculate the schedule time
      tz.initializeTimeZones();
      String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      var currentTime = tz.TZDateTime.now(tz.local);

      var scheduleTime = tz.TZDateTime(
          tz.local,
          currentTime.year,
          currentTime.month,
          currentTime.day,
          datePraysTimes[index].hour,
          datePraysTimes[index].minute);

      // If the scheduled time is in the past, schedule for the next day
      if (scheduleTime.isBefore(currentTime)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      // Re-schedule the alarm with the new sound
      final scheduled = await AlarmHelper.setPrayerAlarm(
        id: index,
        prayerName: praysName[index],
        prayerTime: scheduleTime,
        customSoundPath: soundPath,
      );

      if (!scheduled) return;

      print(
          '✅ [PraysCubit] Alarm re-scheduled successfully with sound: $soundPath');

      // Fajr sound changed → Imsak must follow the same muezzin.
      if (index == 0) {
        await _rescheduleImsakIfEnabled();
      }

      // Re-schedule sub-reminders for this prayer (sound change doesn't affect
      // reminder timing, but the reschedule keeps data consistent).
      await ReminderScheduler.reschedulePrayerReminders(
        prayerIndex: index,
        prayerTime: scheduleTime.toLocal(),
        config: prayerReminderConfigs[index],
        prayerName: praysName[index],
        soundPath: soundPath,
      );
    } catch (e) {
      print('❌ [PraysCubit] Error re-scheduling alarm: $e');
    }
  }

  Future<void> rescheduleAllPrayerNotifications() async {
    print('🔄 [PraysCubit] Rescheduling all prayer notifications...');

    // 1. Check permissions first
    bool hasPermissions = await checkNotificationPermissions();
    if (!hasPermissions) {
      print(
          '⚠️ [PraysCubit] Missing permissions for notifications. Attempting to request...');
      hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        print(
            '❌ [PraysCubit] Permissions denied. Cannot schedule notifications.');
        return;
      }
    }

    // 2. Initialize timezones
    try {
      tz.initializeTimeZones();
      String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      print('❌ [PraysCubit] Error initializing timezones: $e');
      return;
    }

    var currentTime = tz.TZDateTime.now(tz.local);

    // 3. Iterate over all prayers
    for (int i = 0; i < prayList.length; i++) {
      // Only schedule if notification is enabled for this prayer
      if (prayList[i].isNotify) {
        try {
          // Cancel existing notifications first to avoid duplicates
          LocalNotificationService.cancelNotification(i);
          await AlarmHelper.cancelPrayerAlarm(i);

          // Also cancel Iqama notification (index + 400)
          LocalNotificationService.cancelNotification(i + 400);

          // Get sound path
          final soundPath = _adhanSoundPathForPrayer(i);

          // Calculate prayer time
          if (i < datePraysTimes.length) {
            var scheduleTime = tz.TZDateTime(
                tz.local,
                currentTime.year,
                currentTime.month,
                currentTime.day,
                datePraysTimes[i].hour,
                datePraysTimes[i].minute);

            // If time has passed for today, schedule for tomorrow
            if (scheduleTime.isBefore(currentTime)) {
              scheduleTime = scheduleTime.add(const Duration(days: 1));
            }

            // Schedule Adhan Alarm (Background/Terminated)
            final scheduled = await AlarmHelper.setPrayerAlarm(
              id: i,
              prayerName: praysName[i],
              prayerTime: scheduleTime,
              customSoundPath: soundPath,
            );

            if (scheduled) {
              print(
                  '✅ [PraysCubit] Scheduled Adhan for ${praysName[i]} at $scheduleTime');
            }

            // Schedule Iqama Notification (Foreground/Background)
            var iqamaTime =
                scheduleTime.add(Duration(minutes: prayList[i].time.toInt()));

            LocalNotificationService.showDailySchduledNotification(
              i + 400,
              "إقامة ${praysName[i]}",
              soundPath: soundPath,
              iqamaTime.hour,
              iqamaTime.minute,
            );

            print(
                '✅ [PraysCubit] Scheduled Iqama for ${praysName[i]} at $iqamaTime');
          }
        } catch (e) {
          print(
              '❌ [PraysCubit] Error scheduling notification for prayer $i: $e');
        }
      }
    }

    // Reschedule Imsak notification when prayer times change (independent from Fajr)
    await _rescheduleImsakIfEnabled();

    // Schedule sub-reminders for all prayers via WorkManager.
    await _rescheduleAllReminders();
  }

  Future<void> _rescheduleAllReminders() async {
    if (datePraysTimes.length < 7) return;
    // Reload configs from prefs to pick up any changes since last load.
    _loadReminderConfigs();
    final soundPaths = List.generate(
      7,
      (i) => _adhanSoundPathForPrayer(i),
    );
    await ReminderScheduler.rescheduleAllReminders(
      prayerTimes: datePraysTimes,
      configs: prayerReminderConfigs,
      prayerNames: praysName,
      soundPaths: soundPaths,
    );
  }

  void updateFaredaTime(double time, int index) {
    prayList[index].time = time;
    CacheHelper.saveData(key: 'fareeda_resides$index', value: time);
    emit(ChangeFaredaState());
  }

  double faredaTime = 5;

  /// Returns Imsak time (Fajr - 10 minutes) as a plain DateTime for display.
  DateTime? getImsakDateTime() {
    if (datePraysTimes.isEmpty) return null;
    final fajrTime = datePraysTimes[0];
    return fajrTime.subtract(const Duration(minutes: imsakMinutesBeforeFajr));
  }

  /// Computes the next timezone-aware TZDateTime for Imsak (Fajr schedule - 10 min).
  /// Handles the edge case where Imsak has already passed but Fajr hasn't yet
  /// (e.g. now is 04:55, Fajr at 05:00 → Imsak 04:50 already passed → schedule tomorrow).
  tz.TZDateTime? _nextImsakTZDateTime(tz.TZDateTime currentTime) {
    if (datePraysTimes.isEmpty) return null;

    var fajrSchedule = tz.TZDateTime(
      tz.local,
      currentTime.year,
      currentTime.month,
      currentTime.day,
      datePraysTimes[0].hour,
      datePraysTimes[0].minute,
    );
    if (fajrSchedule.isBefore(currentTime)) {
      fajrSchedule = fajrSchedule.add(const Duration(days: 1));
    }

    var imsakSchedule =
        fajrSchedule.subtract(const Duration(minutes: imsakMinutesBeforeFajr));

    // Between Imsak and Fajr: Imsak passed but Fajr still upcoming today.
    // Advance another day so we schedule tomorrow's Imsak.
    if (imsakSchedule.isBefore(currentTime)) {
      fajrSchedule = fajrSchedule.add(const Duration(days: 1));
      imsakSchedule = fajrSchedule
          .subtract(const Duration(minutes: imsakMinutesBeforeFajr));
    }

    return imsakSchedule;
  }

  /// Formatted Imsak time string for display (12h or 24h based on Is24Format).
  String getImsakTimeFormatted() {
    final dt = getImsakDateTime();
    if (dt == null) return '--:--';
    if (Is24Format.is24TimeFormat) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    final format12 = DateFormat('hh:mm a');
    return format12.format(dt);
  }

  /// Toggle Imsak alert on/off. Independent from Fajr alert.
  Future<void> updateImsakNotify(bool value) async {
    isImsakAlertEnabled = value;
    CacheHelper.saveData(key: 'is_imsak_alert_enabled', value: value);
    if (!value) {
      await _cancelImsakNotification();
    } else {
      await _scheduleImsakNotification();
    }
    emit(ChangeFaredaState());
  }

  /// Schedule Imsak adhan via the native AlarmManager pipeline (same as Fajr).
  /// Sound is inherited from Fajr's current reader setting.
  Future<void> _scheduleImsakNotification() async {
    if (datePraysTimes.isEmpty) return;

    tz.initializeTimeZones();
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    final currentTime = tz.TZDateTime.now(tz.local);

    final imsakSchedule = _nextImsakTZDateTime(currentTime);
    if (imsakSchedule == null) return;

    // Inherit Fajr's reader sound; fall back to Alafasi if reader id has no asset.
    final soundPath = _adhanSoundPathForPrayer(0);

    final scheduled = await AlarmHelper.setPrayerAlarm(
      id: imsakNotificationId,
      prayerName: 'الإمساك',
      prayerTime: imsakSchedule,
      customSoundPath: soundPath,
    );
    if (scheduled) {
      print('✅ [PraysCubit] Scheduled Imsak adhan at $imsakSchedule');
    }
  }

  /// Cancel Imsak adhan alarm (native AlarmManager) and local notification.
  Future<void> _cancelImsakNotification() async {
    LocalNotificationService.cancelNotification(imsakNotificationId);
    await AlarmHelper.cancelPrayerAlarm(imsakNotificationId);
  }

  /// Reschedule Imsak when prayer times or Fajr reader change.
  Future<void> _rescheduleImsakIfEnabled() async {
    await _cancelImsakNotification();
    if (isImsakAlertEnabled) {
      await _scheduleImsakNotification();
    }
  }

  Future<void> requestLocation() async {
    emit(LocationLoadingState());
    await getUserLocation();
    if (latitude != 0.0 || longitude != 0.0) {
      getPrays();
    }
    if (latitude == 0.0 || longitude == 0.0) {
      Permission.location.request();
      await getUserLocation();
      emit(LocationFailureState());
    }
  }

  PageController pageController = PageController();
}
