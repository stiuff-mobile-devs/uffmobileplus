import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/utils/leitor_qr_code.dart';

class CatracaOnlineBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<CatracaOnlineController>(
      CatracaOnlineController(),
      permanent: true,
    );

    Get.lazyPut<LeitorQrCodeController>(() => LeitorQrCodeController());
  }
}
