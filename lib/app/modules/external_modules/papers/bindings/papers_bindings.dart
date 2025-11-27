import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/papers/controller/papers_controller.dart';

class PeriodicosBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PapersController>(() => PapersController());
  }
}
