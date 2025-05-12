import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import '../../features/prays_and_times/prays_settings/data/model/pray_model.dart';

List<String> arabicDays = [
  "الأثنين",
  "الثلاثاء",
  "الأربعاء",
  "الخميس",
  "الجمعة",
  "الأحد",
  "السبت",
];

List<String> monthNames = [
  "محرم",
  "صفر",
  "ربيع الأول",
  "ربيع الثاني",
  "جمادى الأولى",
  "جمادى الثانية",
  "رجب",
  "شعبان",
  "رمضان",
  "شوال",
  "ذي القعدة",
  "ذي الحجه",
];

Map<String,String> days = {
  "Sat":"السبت",
  "Sun":"الأحد",
  "Mon":"الأثنين",
  "Tue":"الثلاثاء",
  "Wed":"الأربعاء",
  "Thu":"الخميس",
  "Fri":"الجمعة"
  };


Color kPrimaryColor = const Color(0xFF057107);
Color kBackgroundColor = const Color(0xffF6F5F2);
Color kBlackGrey = const Color(0xff535763);
Color kGreyColor = const Color(0xffD9D9D9);
Color kPinkColor = const Color(0xffFF1C6B);
Color kBlackGreyColor = const Color(0xFFAEAEAE);
List<String> adhanDownloaded = ['false', 'false', 'false', 'false','false'];
double latitude = 0;
double longitude = 0;

LocationPermission permission = LocationPermission.denied;
Future<Position> getUserLocation() async {
  bool serviceEnabled;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    permission = await Geolocator.requestPermission();
    // throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    
  }

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

void fetchLocation() async {
  try {
    Position position = await getUserLocation();
    latitude = position.latitude;
    longitude = position.longitude;
    CacheHelper.saveData(key: 'lat', value: latitude);
    CacheHelper.saveData(key: 'lon', value: longitude);
  } catch (e) {}
}

List<PrayModel> prayList = [
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
];

List<PrayModel> nawafelList = [
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0),
  PrayModel(isNotify: false, reader: "مشاري العفاسي", time: 5, readerId: 0)
];
