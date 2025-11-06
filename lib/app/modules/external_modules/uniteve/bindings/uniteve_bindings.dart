import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/uniteve/controller/uniteve_controller.dart';

class UniteveBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UniteveController>(() => UniteveController());
  }
}