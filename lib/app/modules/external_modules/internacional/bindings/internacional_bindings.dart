import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/internacional/controller/internacional_controller.dart';

class InternacionalBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InternacionalController>(() => InternacionalController());
  }
}