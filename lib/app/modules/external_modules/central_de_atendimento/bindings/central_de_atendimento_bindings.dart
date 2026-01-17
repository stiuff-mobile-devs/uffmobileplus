import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/central_de_atendimento/controller/central_de_atendimento_controller.dart';

class CentralDeAtendimentoBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CentralDeAtendimentoController>(() => CentralDeAtendimentoController());
    }
}