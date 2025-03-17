import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../../../../core/util/constant.dart';
import '../../data/model/prays_model.dart';
import '../../data/repos/prays_repo.dart';

part 'prays_state.dart';

class PraysCubit extends Cubit<PraysState> {
  PraysCubit(this.prayersRepo) : super(PraysInitial()){
    getLocalPraysTimes();
    getPrays();

  }

  PraysRepo prayersRepo;
  Color ringColor = kPinkColor;
  void getLocalPraysTimes(){
    if(CacheHelper.getData(key: "praysTimes")!=null){
      stringPraysTimes=CacheHelper.getData(key: "praysTimes");
    for(int i=0;i<prayList.length;i++){
      if(CacheHelper.getData(key: 'pray_$i')!=null){
        prayList[i].isNotify=CacheHelper.getData(key: 'pray_$i');
      }
    }
    DateTime now = DateTime.now(); // Get today's date
    datePraysTimes = stringPraysTimes.map((time) {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].substring(0,2));
      return DateTime(now.year, now.month, now.day, hour, minute);
    }).toList();

    emit(GetPrayersTimesSuccess(message: ''));
    }
    else{
      getPrays();
    }
    }



  List<String> praysName = [
    "الفجر",
    "الشروق",
    "الظهر",
    "العصر",
    "المغرب",
    "العشاء",
  ];
  List<String>praysImages=[
    "assets/img/fajr_img.png",
    "assets/img/sunrise_img.png",
    "assets/img/zohr_img.png",
    "assets/img/asr_img.png",
    "assets/img/sunset_img.png",
    "assets/img/isha_img.png",
  ];

  List<String> stringPraysTimes = ['00:00', '00:00','00:00', '00:00', '00:00', '00:00'];
  List<DateTime> datePraysTimes = [];

  void assignPrayersTimes() {
    datePraysTimes = [];
    stringPraysTimes[0] = prayersModel.data.timings.Fajr;
    stringPraysTimes[1] = prayersModel.data.timings.Sunrise;
    stringPraysTimes[2] = prayersModel.data.timings.Dhuhr;
    stringPraysTimes[3] = prayersModel.data.timings.Asr;
    stringPraysTimes[4] = prayersModel.data.timings.Maghrib;
    stringPraysTimes[5] = prayersModel.data.timings.Isha;
    CacheHelper.saveData(key: 'praysTimes', value: stringPraysTimes);
    DateTime now = DateTime.now(); // Get today's date
    datePraysTimes = stringPraysTimes.map((time) {
      List<String> parts = time.split(':');
      print(parts);
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].substring(0,2));
      return DateTime(now.year, now.month, now.day, hour, minute);
    }).toList();
    for (var time in datePraysTimes) {
      print(time);
    }
  }

  int neartestPrayIndex=0;
  DateTime? getNearestPrayerTime() {
    DateTime now = DateTime.now();
    DateTime? nearestTime;
    bool isFound=false;
    for (int i=0;i<datePraysTimes.length;i++) {
      if (datePraysTimes[i].isAfter(now)) {
        if (nearestTime == null || datePraysTimes[i].isBefore(nearestTime)) {
          nearestTime = datePraysTimes[i];
          neartestPrayIndex=i;
          isFound=true;
        }
      }
    }
    if(!isFound){
      nearestTime=datePraysTimes[0];
      neartestPrayIndex=0;
      isFound=true;
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
              Maghrib: 'Maghrib',
              Isha: 'Isha',
          ),date: '', hijriDate: ''));

  Future<void> getPrays() async {
    if (latitude == 0.0 || longitude == 0.0) {
      emit(LocationMissedState(message: "من فضلك قم بتحديد موقعك"));
      return;
    }
    emit(GetPraysTimesLoading());
    var result = await prayersRepo.getPrayersTimes();
    result.fold(
        (l) => emit(GetPrayersTimesError(error: "حدث خطأ ما! اعد المحاولة")),
        (response) {
      if (response.data['success'] == false) {
        if (response.data['message'].contains("Validation")) {
          emit(GetPrayersTimesError(
              error:
                  "الرجاء الغاء تفعيل برامج الVPN والتحقق من الاتصال بالانترنت"));
          return;
        }
        emit(GetPrayersTimesError(error: response.data['message']));
        return;
      }
      try {
        print(response.data);
        prayersModel = PrayersModel.fromJson(response.data);
        print(prayersModel.message);
        assignPrayersTimes();
        // remainingTimes();
        // LocalNotificationService.cancelAlllNotification();
        // for (int i = 0; i < prayerTimes.length; i++) {
        //   LocalNotificationService.showDailySchduledNotification(adhanDownloaded[prayList[i].readerId],prayerTimes[i].hour,prayerTimes[i].minute);
        //       i, praysName[i], praysName[i],
        //   prayerTimes[i]
        //   );
        // }
        emit(GetPrayersTimesSuccess(message: prayersModel.message));
      } catch (e) {
        emit(GetPrayersTimesError(error: e.toString()));
      }
    });
  }


  String reader = 'مشاري العفاسي';
  String lastReader = 'مشاري العفاسي';

  List<String> readers = [
    "مشاري العفاسي",
    "ياسر الدوسري",
    "الحصري",
    "عبدالباسط عبدالصمد",
  ];

  void changeReader(String value) {
    reader = value;
    emit(ChangeReaderState());
  }

  void confirmReader() {
    lastReader = reader;
    emit(ChangeReaderState());
  }

  bool switchValue = false;

  void changeSwitchValue(bool value) {
    switchValue = value;
    emit(ChangeSwitchState());
  }

  bool isExpand = false;

  bool isFaredaExpand = false;

  void collapseFareda() {
    for (int i = 0; i < faredaExpandationValue.length; i++) {
      faredaExpandationValue[i] = false;
    }
    isFaredaExpand = false;
    emit(ExpandFaredaState());
  }

  void changeSliderValue() {
    emit(ChangeSliderValueState());
  }

  void expandFareda(int index) async {
    collapseFareda();
    Future.delayed(const Duration(milliseconds: 200), () {
      faredaExpandationValue[index] = true;
      isFaredaExpand = true;
      emit(ExpandFaredaState());
    });
  }

  void changeExpand(bool value) {
    isExpand = value;
    emit(ChangeExpandState());
  }



  void updateFaredaNotify(bool value, int index) async{
    prayList[index].isNotify = value;
    if (!value) {
      LocalNotificationService.cancelNotification(index);
      CacheHelper.saveData(key: 'pray_${index}', value: value);
    }
    if (value) {
      LocalNotificationService.showBasicNotification();
      print(datePraysTimes[index].hour);
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('alarm_hour_$index', datePraysTimes[index].hour);
      prefs.setInt('alarm_minute_$index', datePraysTimes[index].minute);
      CacheHelper.saveData(key: 'pray_${index}', value: value);
      adhanDownloaded.length > 0 ?
      LocalNotificationService.showDailySchduledNotification(index,praysName[index],adhanDownloaded[prayList[index].readerId],datePraysTimes[index].hour,datePraysTimes[index].minute):
      LocalNotificationService.showDailySchduledNotification(index,praysName[index],'',datePraysTimes[index].hour,datePraysTimes[index].minute);
    }
    emit(ChangeFaredaState());
  }

  void updateFaredaReader(String name, int index) {
    prayList[index].reader = name;
    emit(ChangeFaredaState());
  }

  void updateFaredaTime(double time, int index) {
    prayList[index].time = time;
    emit(ChangeFaredaState());
  }

  String faredaReader = "مشاري العفاسي";
  double faredaTime = 5;
  List<bool> faredaExpandationValue = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  Future<void> requestLocation() async {
    emit(LocationLoadingState());
    await getUserLocation();
    if(latitude != 0.0 || longitude != 0.0){
    getPrays();
    }
    if(latitude==0.0||longitude==0.0){
    emit(LocationFailureState());
    }
  }
  PageController pageController = PageController();
}
