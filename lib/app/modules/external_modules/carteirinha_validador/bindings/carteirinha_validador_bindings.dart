import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_validador/controller/carteirinha_validador_controller.dart';

class CarteirinhaValidadorBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CarteirinhaValidadorController>(
      () => CarteirinhaValidadorController(),
    );
  }
}