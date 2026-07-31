import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/calendar_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/google_groups_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/tracking_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/permissions_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/user_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';

class MonitoraUffBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<TrackingController>(() => TrackingController());
    Get.lazyPut<PermissionsController>(() => PermissionsController());
    Get.lazyPut(() => AuthGoogleController()); 
    Get.lazyPut(() => GoogleGroupsController()); 
    Get.lazyPut(() => CalendarController());
  }
}
