import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_iduff_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class SettingsController extends GetxController {

SettingsController();
  late final UserIduffController _userIduffController;
  @override
  onInit() {
    _userIduffController = Get.find<UserIduffController>();
    super.onInit();
  }
  logoutIduff(){
    _userIduffController.deleteUserIduffModel();
    Get.offAllNamed(Routes.LOGIN);
  }
}