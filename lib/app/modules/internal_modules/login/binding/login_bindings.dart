import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.appendTranslations({
      'pt_BR' : {
        'carteirinha_digital' : 'Carteirinha Digital',
        'entrar' : 'Entrar',
        'escolha_entrada' : 'Escolha uma forma parar entrar',
        'sem_login' : 'Sem Login'
      }
    });
  }
}
