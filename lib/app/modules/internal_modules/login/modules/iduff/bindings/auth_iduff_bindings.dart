import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/controller/auth_iduff_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';

class AuthIduffBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthIduffService>(AuthIduffService(), permanent: true);
    Get.lazyPut<AuthIduffController>(() => AuthIduffController());
  }
}
