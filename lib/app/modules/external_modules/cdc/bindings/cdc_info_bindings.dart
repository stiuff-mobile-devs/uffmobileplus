import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_info_controller.dart';

class CdcInfoBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CdcInfoController>(() => CdcInfoController());
  }
}
