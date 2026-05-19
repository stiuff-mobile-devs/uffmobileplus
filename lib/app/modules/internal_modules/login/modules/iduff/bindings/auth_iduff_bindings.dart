import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/controller/auth_iduff_controller.dart';

class AuthIduffBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthIduffController>(() => AuthIduffController());
  }
}
