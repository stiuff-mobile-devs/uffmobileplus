import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/bibliotecas/web_page/controller/web_controller.dart';

class BibliotecasWebBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BibliotecasWebController>(() => BibliotecasWebController());
  }
}