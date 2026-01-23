import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/location_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/monitora_uff_controller.dart';

class MonitoraUffBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonitoraUffController>(() => MonitoraUffController());
    Get.lazyPut<LocationService>(() => LocationService());
  }
}
