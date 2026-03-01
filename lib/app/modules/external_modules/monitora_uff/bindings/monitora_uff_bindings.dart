import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/tracking_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/permissions_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/user_controller.dart';

class MonitoraUffBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<TrackingController>(() => TrackingController());
    Get.lazyPut<PermissionsController>(() => PermissionsController());
  }
}
