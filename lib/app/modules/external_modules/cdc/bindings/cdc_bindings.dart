import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';

class CdcBindings implements Bindings {
@override
void dependencies() {
  Get.lazyPut<CdcController>(
    () => CdcController(),
  );
  }
}