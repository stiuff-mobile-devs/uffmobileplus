import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/controller/carteirinha_info_controller.dart';

class CarteirinhaInfoBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CarteirinhaInfoController>(() => CarteirinhaInfoController());
  }
}
