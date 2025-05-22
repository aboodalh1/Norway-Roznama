import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/adhan_model.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/adhan_repo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/util/constant.dart';

part 'prays_settings_state.dart';

class PraysSettingsCubit extends Cubit<PraysSettingsState> {
  PraysSettingsCubit(this.adhanRepo) : super(PraysSettingsInitial()) {
    if (CacheHelper.getData(key: 'is_adhan_links_downloaded') != null) {
      isAdhanLinkDownloaded =
          CacheHelper.getData(key: 'is_adhan_links_downloaded');
    }
    if (CacheHelper.getData(key: 'adhan_list') != null) {
      adhanList = CacheHelper.getData(key: 'adhan_list');
    }
    for(int i=0; i<prayList.length;i++){
      if(  CacheHelper.getData(
          key: "pray_reader$i")!=null){
        prayList[i].readerId =CacheHelper.getData(
            key: "pray_reader$i");
      }
      prayList[i].reader = readers[prayList[i].readerId];
    }
    getAdhan();
    if (CacheHelper.getData(key: 'adhan_downloaded') != null) {
      adhanDownloaded = CacheHelper.getData(key: 'adhan_downloaded');
    } else {
      adhanDownloaded = [
        'false',
        'false',
        'false',
        'false',
      ];
      CacheHelper.saveData(key: 'adhan_downloaded', value: adhanDownloaded);
    }
  }

  List<bool> isDonwloading = [
    false,
    false,
    false,
    false,
  ];
  List<bool> isPlaying = [
    false,
    false,
    false,
    false,
  ];

  String savePath = ''; 
  AdhanRepo adhanRepo;
  Future<String?> downloadAdhan(int index,String url ) async {
    emit(AdhanDownloadLoading());
    try {
      // طلب صلاحية الوصول للتخزين


      // الوصول إلى مجلد التنزيلات
      final Directory? downloadsDir = Directory('/storage/emulated/0/Download');

      if (downloadsDir == null || !downloadsDir.existsSync()) {
        throw Exception("Downloads folder not found");
      }

      String name = index == 0
          ? "alafasi"
          : index == 1
          ? "yaser"
          : index == 2
          ? "alhusari"
          : index == 3
          ? "abd_albaset"
          : "default";

      String savePath = "${downloadsDir.path}/$name.mp3";

      // تحميل الملف
      await Dio().download(url, savePath);

      // إعلام النظام بوجود ملف وسائط جديد
      await MediaScanner.loadMedia(path: savePath);

      // تحديث الحالة أو الكاش
      adhanDownloaded[index] = savePath;
      CacheHelper.saveData(key: 'adhan_downloaded', value: adhanDownloaded);

      isDonwloading[index] = false;

      emit(AdhanDownloadSuccess(message: "تم تحميل الأذان بنجاح"));
      return savePath;

    } catch (e) {
      isDonwloading[index] = false;
      emit(AdhanDownloadFailure(error: 'فشل تحميل الأذان'));
      return null;
    }
  }

  String reader = 'مشاري العفاسي';
  String lastReader = 'مشاري العفاسي';

  bool isAdhanLinkDownloaded = false;

  String adhanList = '';

  List<String> readers = [
    "مشاري العفاسي",
    "ياسر الدوسري",
    "محمود الحصري",
    "عبدالباسط عبدالصمد",
    "صوت الاشعار الافتراضي",
  ];

  AdhanModel adhanModel = AdhanModel(success: false, message: '', data: []);

  final player = AudioPlayer();
  void playLocalAdhan(int index) async {
    await player.play(DeviceFileSource(adhanDownloaded[index]));
  }

  Future<void> getAdhan() async {
    if (!isAdhanLinkDownloaded) emit(GetAdhanLoading());
    var result = await adhanRepo.getAdhan();
    result.fold((failure) {}, (response) {
      if (response.data['success'] == false) {
        if (response.data['message'].contains("Validation")) {
          if (!isAdhanLinkDownloaded)
            emit(GetAdhanFailure(error: "الرجاء الغاء تفعيل برامج الVPN"));
          return;
        }
        if (!isAdhanLinkDownloaded)
          emit(GetAdhanFailure(error: response.data['message']));
        return;
      }
      adhanModel = AdhanModel.fromJson(response.data);
      isAdhanLinkDownloaded = true;
      CacheHelper.saveData(key: 'is_adhan_links_downloaded', value: true);
      Map<String, dynamic> adhanList = jsonDecode(json.encode(response.data));
      final adhanEncode = jsonEncode(adhanList);
      CacheHelper.saveData(key: 'adhan_list', value: adhanEncode);
      emit(GetAdhanSuccess(
        adhanModel: AdhanModel.fromJson(response.data),
      ));
    });
  }

  void changeReader(String value) {
    faredaReader = value;
    emit(ChangeReaderState());
  }

  void confirmReader(int index) {
    lastReader = faredaReader;
    prayList[index].reader = faredaReader;
    prayList[index].readerId = faredaReader == "مشاري العفاسي"
        ? 0
        : faredaReader == "ياسر الدوسري"
            ? 1
            : faredaReader == "محمود الحصري"
                ? 2
                : faredaReader == "عبدالباسط عبدالصمد"?3:4;
    CacheHelper.saveData(
        key: "pray_reader$index", value: prayList[index].readerId);
    emit(ChangeReaderState());
  }

  bool switchValue = false;

  void changeSwitchValue(bool value) {
    switchValue = value;
    emit(ChangeSwitchState());
  }

  bool isExpand = true;

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
    false,
  ];
}
