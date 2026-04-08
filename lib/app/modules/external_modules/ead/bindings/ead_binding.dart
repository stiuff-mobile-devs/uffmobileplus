import 'package:get/get.dart';
import '../controller/ead_controller.dart';

class EadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EadController>(() => EadController());
  }
}
