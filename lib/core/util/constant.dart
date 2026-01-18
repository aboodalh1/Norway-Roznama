import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../features/prays_and_times/prays_settings/data/model/pray_model.dart';
import 'package:just_audio/just_audio.dart';


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
/// Legacy list for downloaded adhan files.
/// Note: For scheduling alarms, use AdhanSoundMapper instead.
/// Backend IDs: 1=Alafasi, 2=Yaser, 3=Alhusari, 4=Abd Albaset
/// This list uses 0-based indices but backend IDs are 1-based.
List<String> adhanDownloaded = [
  'assets/sounds/alafasi.mp3',    // Index 0 (Backend ID 1)
  'assets/sounds/yaser.mp3',      // Index 1 (Backend ID 2)
  'assets/sounds/alhusari.mp3',   // Index 2 (Backend ID 3)
  'assets/sounds/abd_albaset.mp3', // Index 3 (Backend ID 4)
  'false'                          // Index 4 (Backend ID 5 - default)
];
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

// Create a player instance

// Create an AudioPlayer instance. Keep it persistent if you manage multiple sounds.
final AudioPlayer _audioPlayer = AudioPlayer();

/// Plays a custom sound using just_audio.
///
/// [assetPath]: The path to your audio asset in the Flutter project (e.g., 'assets/sounds/alarm.mp3').
Future<void> playCustomAlarmSound(String assetPath) async {
  try {
    await _audioPlayer.setAsset(assetPath); // Load the audio file
    await _audioPlayer.play(); // Start playing
    // Optionally, loop the sound:
    await _audioPlayer.setLoopMode(LoopMode.one);
    print('Playing custom sound from assets: $assetPath');
  } catch (e) {
    print("Error playing audio with just_audio: $e");
  }
}

/// Stops the currently playing audio.
void stopCustomAlarmSound() {
  _audioPlayer.stop();
  print('Custom alarm sound stopped.');
}

/// Disposes the audio player to release resources. Call this when your app is closing or player is no longer needed.
void disposeAudioPlayer() {
  _audioPlayer.dispose();
  print('Audio player disposed.');
}




Future<bool> requestPermissions() async {
  print('🔐 Requesting permissions...');
  bool allGranted = true;

  if (await Permission.notification.isDenied) {
    final status = await Permission.notification.request();
    if (!status.isGranted) allGranted = false;
  }

  if (Platform.isAndroid) {
    // Request POST_NOTIFICATIONS permission for Android 13+
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
       if (!status.isGranted) allGranted = false;
    }

    // Request SCHEDULE_EXACT_ALARM for Android 12+ (required for exact alarms)
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
       if (!status.isGranted) allGranted = false;
    }
    
    // Request USE_FULL_SCREEN_INTENT for Android 10+ for heads-up notifications
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
    
    // Request ignore battery optimizations for reliable alarm delivery
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  print('✅ Permissions requested, success: $allGranted');
  return allGranted;
}

Future<bool> checkNotificationPermissions() async {
  if (Platform.isAndroid) {
    // Check notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      print('❌ Notification permission denied');
      return false;
    }

    // Check exact alarm permission (Android 12+)
    // Note: This permission is usually granted by default but user can revoke it
    if (await Permission.scheduleExactAlarm.isDenied) {
      print('❌ Exact alarm permission denied');
      return false;
    }
  }
  
  // Also check general notification permission
  if (await Permission.notification.isDenied) {
    return false;
  }

  return true;
}
