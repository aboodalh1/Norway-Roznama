import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/util/constant.dart';
import '../../data/model/prays_model.dart';
import '../../data/repos/prays_repo.dart';
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

      // Check if the mobile uses 24-hour format and convert if necessary
      if (Is24Format.is24TimeFormat) convertTo24HourFormat();

      // Update the datePraysTimes based on the converted prayer times
      DateTime now = DateTime.now(); // Get today's date
      datePraysTimes = stringPraysTimes12Format.map((time) {
        List<String> parts = time.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].substring(0, 2));
        return DateTime(now.year, now.month, now.day, hour, minute);
      }).toList();

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
  }

  DateTime? getNearestPrayTime() {
    DateTime now = DateTime.now();
    DateTime? nearestTime;
    bool isFound = false;
    for (int i = 0; i < datePraysTimes.length; i++) {
      if (datePraysTimes[i].isAfter(now)) {
        if (nearestTime == null || datePraysTimes[i].isBefore(nearestTime)) {
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
      LocalNotificationService.cancelNotification(index);
      CacheHelper.saveData(key: 'pray_$index', value: value);
    }
    if (value) {
      String? soundPath = adhanDownloaded[prayList[index].readerId];
      if (soundPath.isNotEmpty) {
        switch (prayList[index].readerId) {
          case 0:
            soundPath = "alafasi";
            break;
          case 1:
            soundPath = "yaser";
            break;
          case 2:
            soundPath = "alhusari";
            break;
          case 3:
            soundPath = "abd_albaset";
            break;
          default:
            soundPath = null;
        }
        LocalNotificationService.showDailySchduledNotification(
          index,
          praysName[index],
          soundPath: soundPath, // Extract the file name without extension
          datePraysTimes[index].hour,
          datePraysTimes[index].minute,
        );
        LocalNotificationService.showDailySchduledNotification(
          index + 400,
          "إقامة " + praysName[index],
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
    }
    emit(ChangeFaredaState());
  }

  void updateFaredaTime(double time, int index) {
    prayList[index].time = time;
    CacheHelper.saveData(key: 'fareeda_resides$index', value: time);
    emit(ChangeFaredaState());
  }

  double faredaTime = 5;

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
