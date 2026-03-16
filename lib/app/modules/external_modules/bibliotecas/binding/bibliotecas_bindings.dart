import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/bibliotecas/controller/bibliotecas_controller.dart';

class BibliotecasBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BibliotecasController>(() => BibliotecasController(),);
  }
}