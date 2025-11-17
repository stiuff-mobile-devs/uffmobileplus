import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_carteirinha_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/controller/carteirinha_digital_controller.dart';

class CarteirinhaDigitalBindings implements Bindings {
@override
void dependencies() {
  Get.lazyPut<ExternalCarteirinhaService>(() => ExternalCarteirinhaService());
  Get.lazyPut<CarteirinhaDigitalController>(() => CarteirinhaDigitalController());
  Get.appendTranslations({
  'pt_BR' : {
    'carteirinha_digital' : 'Carteirinha Digital',
    'documento' : 'Documento',
    'matricula' : 'Matrícula', 
    'validade' : 'Validade',
    'curso' : 'Curso',
    'validador_instrucao' : 'Valide o código gerado utilizando o aplicativo' 
  },
  'en_US' : {
    'carteirinha_digital' : 'Digital ID Card',
    'documento' : 'Document',
    'matricula' : 'ID',
    'validade' : 'Expiration Date',
    'curso' : 'Course',
    'validador_instrucao' : 'Validate the generated code by using the application'
  }
});
  }
}