import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_catraca_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/leitor_qr_code.dart';

class CatracaOnlineBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<ExternalCatracaService>(ExternalCatracaService(), permanent: true);

    Get.put<CatracaOnlineController>(
      CatracaOnlineController(),
      permanent: true,
    );

    Get.lazyPut<LeitorQrCodeController>(() => LeitorQrCodeController());
  }
}
