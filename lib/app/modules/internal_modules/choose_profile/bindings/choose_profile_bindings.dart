import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/choose_profile/controller/choose_profile_controller.dart';

class ChooseProfileBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChooseProfileController>(() => ChooseProfileController());
    Get.appendTranslations({
      'pt_BR' : {
        'escolha_perfil' : 'Escolha seu Perfil',
        'carteirinha_digital' : 'Carteirinha Digital',
        'atualizar' : 'Atualizar',
        'graduacao' : 'Graduação',
        'status' : 'Status',
        'matricula' : 'Matrícula',
        'pos_graduacao' : 'Pós-Graduação',
        'tecnico_administrativo' : 'Técnico Administrativo',
        'docente' : 'Docente',
        'terceirizado' : 'Terceirizado'
      }
    });
  }
}
