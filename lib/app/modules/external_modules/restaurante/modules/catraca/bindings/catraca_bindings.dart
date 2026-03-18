import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/leitor_qr_code.dart';

class CatracaOnlineBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<CatracaController>(
      CatracaController(),
      permanent: true,
    );

    Get.lazyPut<LeitorQrCodeController>(() => LeitorQrCodeController());
  }
}
