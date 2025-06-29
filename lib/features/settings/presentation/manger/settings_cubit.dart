import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/features/settings/presentation/data/settings_tile_model.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  List<SettingsTile>settingsTiles=[
    SettingsTile(icon: "assets/icons/advice.png",
        title: "نصيحة لنا", isSwitch: false,
    ),
    SettingsTile(icon: "assets/icons/translate.png",
        title: "تغيير اللغة", isSwitch: false,
    ),
    SettingsTile(icon: "assets/icons/disable_notifications.png",
        title: "تعطيل جميع التنبيهات", isSwitch: true),

  ];
  bool switchValue = false;
  changeSwitchValue(bool value){
    switchValue = value;
    if(switchValue){
      CacheHelper.saveData(key: "is_muted", value: true);
    }
    else {
      CacheHelper.saveData(key: "is_muted", value: false);
    }
    emit(ChangeSwitchValue());
  }
}
