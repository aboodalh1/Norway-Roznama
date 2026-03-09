import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:norway_roznama_new_project/alarm_helper.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/adhan_sound_mapper.dart';
import 'package:norway_roznama_new_project/notification_service.dart';
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/util/constant.dart';
import '../../data/model/prays_model.dart';
import '../../data/repos/prays_repo.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
part 'prays_state.dart';

class PraysCubit extends Cubit<PraysState> {
  PraysCubit(this.prayersRepo) : super(PraysInitial()) {
    getLocalPraysTimes();
  }

  PraysRepo prayersRepo;

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
        isImsakAlertEnabled = CacheHelper.getData(key: 'is_imsak_alert_enabled');
      }
      convertTo24HourFormat();

      DateTime now = DateTime.now(); // Get today's date
      datePraysTimes = stringPraysTimes24Format.map((time) {
        List<String> parts = time.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].substring(0, 2));
        return DateTime(now.year, now.month, now.day, hour, minute);
      }).toList();
      
      // Reschedule notifications after loading local times
      rescheduleAllPrayerNotifications();

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
      CacheHelper.saveData(key: 'pray_$index', value: value);
    }
    if (value) {
      // Use AdhanSoundMapper to get asset path from backend ID (1-4)
      String? soundPath =
          AdhanSoundMapper.getAssetPath(prayList[index].readerId);
      if (soundPath != null && soundPath.isNotEmpty) {
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
        await AlarmHelper.setPrayerAlarm(
          id: index,
          prayerName: praysName[index],
          prayerTime: scheduleTime,
          customSoundPath: soundPath,
        );

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
      } else {}
    } else {}
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
    final soundPath = AdhanSoundMapper.getAssetPath(prayList[index].readerId);

    if (soundPath == null || soundPath.isEmpty) {
      print(
          '⚠️ [PraysCubit] No valid sound path for readerId: ${prayList[index].readerId}');
      return;
    }

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
      await AlarmHelper.setPrayerAlarm(
        id: index,
        prayerName: praysName[index],
        prayerTime: scheduleTime,
        customSoundPath: soundPath,
      );

      print(
          '✅ [PraysCubit] Alarm re-scheduled successfully with sound: $soundPath');
    } catch (e) {
      print('❌ [PraysCubit] Error re-scheduling alarm: $e');
    }
  }

  Future<void> rescheduleAllPrayerNotifications() async {
    print('🔄 [PraysCubit] Rescheduling all prayer notifications...');

    // 1. Check permissions first
    bool hasPermissions = await checkNotificationPermissions();
    if (!hasPermissions) {
      print('⚠️ [PraysCubit] Missing permissions for notifications. Attempting to request...');
      hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        print('❌ [PraysCubit] Permissions denied. Cannot schedule notifications.');
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
          String? soundPath = AdhanSoundMapper.getAssetPath(prayList[i].readerId);
          if (soundPath == null || soundPath.isEmpty) {
            // Default to Alafasi if sound not found
            soundPath = AdhanSoundMapper.getAssetPath(1);
          }
          
          if (soundPath != null && soundPath.isNotEmpty) {
             // Calculate prayer time
             if (i < datePraysTimes.length) {
                var scheduleTime = tz.TZDateTime(
                    tz.local,
                    currentTime.year,
                    currentTime.month,
                    currentTime.day,
                    datePraysTimes[i].hour,
                    datePraysTimes[i].minute
                );

                // If time has passed for today, schedule for tomorrow
                if (scheduleTime.isBefore(currentTime)) {
                  scheduleTime = scheduleTime.add(const Duration(days: 1));
                }

                // Schedule Adhan Alarm (Background/Terminated)
                await AlarmHelper.setPrayerAlarm(
                  id: i,
                  prayerName: praysName[i],
                  prayerTime: scheduleTime,
                  customSoundPath: soundPath,
                );
                
                print('✅ [PraysCubit] Scheduled Adhan for ${praysName[i]} at $scheduleTime');

                // Schedule Iqama Notification (Foreground/Background)
                var iqamaTime = scheduleTime.add(Duration(minutes: prayList[i].time.toInt()));
                
                LocalNotificationService.showDailySchduledNotification(
                  i + 400,
                  "إقامة ${praysName[i]}",
                  soundPath: soundPath, 
                  iqamaTime.hour,
                  iqamaTime.minute,
                );
                
                print('✅ [PraysCubit] Scheduled Iqama for ${praysName[i]} at $iqamaTime');
             }
          }
        } catch (e) {
          print('❌ [PraysCubit] Error scheduling notification for prayer $i: $e');
        }
      }
    }

    // Reschedule Imsak notification when prayer times change (independent from Fajr)
    await _rescheduleImsakIfEnabled();
  }

  void updateFaredaTime(double time, int index) {
    prayList[index].time = time;
    CacheHelper.saveData(key: 'fareeda_resides$index', value: time);
    emit(ChangeFaredaState());
  }

  double faredaTime = 5;

  /// Returns Imsak time (Fajr - 10 minutes). Handles midnight crossover:
  /// e.g. Fajr 00:05 -> Imsak 23:55 previous day. We pass hour/minute to the
  /// scheduler which uses current day; the scheduler correctly finds the next
  /// occurrence (e.g. tonight 23:55 if now is after midnight).
  DateTime? getImsakDateTime() {
    if (datePraysTimes.isEmpty) return null;
    final fajrTime = datePraysTimes[0];
    return fajrTime.subtract(const Duration(minutes: imsakMinutesBeforeFajr));
  }

  /// Formatted Imsak time string for display (12h or 24h based on Is24Format).
  String getImsakTimeFormatted() {
    final dt = getImsakDateTime();
    if (dt == null) return '--:--';
    // Use same format as prayer times - stringPraysTimes12Format/24Format
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
      LocalNotificationService.cancelNotification(imsakNotificationId);
    } else {
      await _scheduleImsakNotification();
    }
    emit(ChangeFaredaState());
  }

  /// Schedule Imsak notification. Called when enabled or when prayer times are refreshed.
  Future<void> _scheduleImsakNotification() async {
    final imsakDt = getImsakDateTime();
    if (imsakDt == null) return;
    LocalNotificationService.showDailySchduledNotification(
      imsakNotificationId,
      'وقت الإمساك',
      imsakDt.hour,
      imsakDt.minute,
      body: 'حان الآن وقت الإمساك، بقي 10 دقائق على أذان الفجر.',
    );
    print('✅ [PraysCubit] Scheduled Imsak at $imsakDt');
  }

  /// Cancel Imsak notification.
  void _cancelImsakNotification() {
    LocalNotificationService.cancelNotification(imsakNotificationId);
  }

  /// Reschedule Imsak notification when prayer times change. Called from rescheduleAllPrayerNotifications.
  Future<void> _rescheduleImsakIfEnabled() async {
    _cancelImsakNotification();
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
