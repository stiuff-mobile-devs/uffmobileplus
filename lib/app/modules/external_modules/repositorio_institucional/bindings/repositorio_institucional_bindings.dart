import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/repositorio_institucional/controller/repositorio_institucional_controller.dart';

class RepositorioInstitucionalBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RepositorioInstitucionalController>(() => RepositorioInstitucionalController());
  }
}