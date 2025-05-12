import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/notification_service.dart';

part 'haj_state.dart';

class HajCubit extends Cubit<HajState> {
  HajCubit() : super(HajInitial()) {
    if (CacheHelper.getData(key: 'haj') != null) {
      switchValue = CacheHelper.getData(key: "haj");
    }
  }

  bool switchValue = false;

  void changeSwitchValue(bool value) {
    switchValue = value;
    emit(HajChangeSwitch());
  }

  void confirmHaj() {
    if (switchValue) {
      LocalNotificationService.scheduleMultipleDaysMonthlyNotification(
          1504, "تذكير مواعيد الحج", "soundPath", 12, 12, [8]);
    } else {
      LocalNotificationService.cancelNotification(1504);
    }
    CacheHelper.saveData(key: "haj", value: switchValue);
  }
}
