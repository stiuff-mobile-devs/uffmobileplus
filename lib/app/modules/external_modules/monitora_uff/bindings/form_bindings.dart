import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/form_controller.dart';

class FormBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormController>(() => FormController());
  }
}
