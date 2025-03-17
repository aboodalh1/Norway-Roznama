import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';
// steps
//1.init work manager
//2.excute our task.
//3.register our task in work manager

class WorkManagerService {

  // void registerMyTask() async {
  //   await Workmanager().registerPeriodicTask(
  //     'id1',
  //     'show simple notification123123123123',
  //     frequency: const Duration(minutes: 15),
  //
  //   );
  // }

  //init work manager service
  Future<void> init() async {
    await Workmanager().initialize(actionTask, isInDebugMode: true);
    // registerMyTask();
  }

  void cancelTask() {
    Workmanager().cancelAll();
  }


  void cancelTaskById(String id) {
    Workmanager().cancelByUniqueName(id);
  }


}
@pragma('vm-entry-point')
void actionTask() {
  //show notification
  Workmanager().executeTask((taskName, inputData) {
    // LocalNotificationService.showDailySchduledNotification(0,'','Notification Title', 9, 0);
    return Future.value(true);
  });
}
//1.schedule notification at 9 pm.
//2.execute for this notification.