import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/controller/busuff_controller.dart';

class BusuffBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<BusuffController>(
    () => BusuffController(),
  );
  }
}