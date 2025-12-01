import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_carteirinha_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/controller/carteirinha_digital_controller.dart';

class CarteirinhaDigitalBindings implements Bindings {
@override
void dependencies() {
    Get.lazyPut<ExternalCarteirinhaService>(() => ExternalCarteirinhaService());  
    Get.lazyPut<CarteirinhaDigitalController>(() => CarteirinhaDigitalController());  
  }
}