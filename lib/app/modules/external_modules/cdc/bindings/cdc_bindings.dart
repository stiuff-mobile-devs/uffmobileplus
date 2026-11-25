import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_archive_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/repository/cdc_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/services/cdc_service.dart';

class CdcBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CdcProvider>(() => CdcProvider());
    Get.lazyPut<CdcArchiveProvider>(() => CdcArchiveProvider());
    Get.lazyPut<CdcRepository>(
      () => CdcRepository(Get.find(), Get.find()),
    );
    Get.lazyPut<CdcService>(() => CdcService());
    Get.lazyPut<CdcController>(
      () => CdcController(Get.find(), Get.find()),
    );
  }
}
