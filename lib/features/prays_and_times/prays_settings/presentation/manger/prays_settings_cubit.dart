import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/adhan_sound_mapper.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/model/adhan_model.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/adhan_repo.dart';
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
    for (int i = 0; i < prayList.length; i++) {
      if (CacheHelper.getData(key: "pray_reader$i") != null) {
        int cachedReaderId = CacheHelper.getData(key: "pray_reader$i");
        
        // Migrate old IDs (0-3) to new backend IDs (1-4) for backward compatibility
        if (cachedReaderId >= 0 && cachedReaderId <= 3) {
          cachedReaderId = cachedReaderId + 1; // 0->1, 1->2, 2->3, 3->4
          CacheHelper.saveData(key: "pray_reader$i", value: cachedReaderId);
        }
        
        prayList[i].readerId = cachedReaderId;
      }
      
      // Map backend ID (1-4) to reader name using AdhanSoundMapper
      final readerName = AdhanSoundMapper.getReaderNameFromBackendId(prayList[i].readerId);
      if (readerName != null && readerName.isNotEmpty) {
        prayList[i].reader = readerName;
      } else {
        // Default to Alafasi if not found
        prayList[i].reader = 'مشاري العفاسي';
        prayList[i].readerId = 1;
      }
    }
    getAdhan();
    if (CacheHelper.getData(key: 'adhan_downloaded') != null) {
      adhanDownloaded = CacheHelper.getData(key: 'adhan_downloaded');
    } else {
      adhanDownloaded = [
        'assets/sounds/alafasi.mp3',
        'assets/sounds/yaser.mp3',
        'assets/sounds/alhusari.mp3',
        'assets/sounds/abd_albaset.mp3',
        'false'
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

  Future<String?> downloadAdhan(int index, String url) async {
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

      String savePath = "assets/sounds/$name.mp3";

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
    String selectedAzan = index == 0
        ? "alafasi"
        : index == 1
            ? "yaser"
            : index == 2
                ? "alhusari"
                : index == 3
                    ? "abd_albaset"
                    : "default";
    await player.play(AssetSource("sounds/$selectedAzan.mp3"));
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
    print(value);
    emit(ChangeReaderState());
  }

  void confirmReader(int index) {
    lastReader = faredaReader;
    prayList[index].reader = faredaReader;
    
    // Use AdhanSoundMapper to get backend ID from reader name
    // Backend IDs: 1=Alafasi, 2=Yaser, 3=Alhusari, 4=Abd Albaset, 5=Default
    prayList[index].readerId = AdhanSoundMapper.getBackendIdFromReaderName(faredaReader) ?? 1;
    
    CacheHelper.saveData(
        key: "pray_reader$index", value: prayList[index].readerId);
    
    final soundPath = AdhanSoundMapper.getAssetPath(prayList[index].readerId);
    print('✅ [PraysSettingsCubit] Reader confirmed: $faredaReader (ID: ${prayList[index].readerId}), sound: $soundPath');
    
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
