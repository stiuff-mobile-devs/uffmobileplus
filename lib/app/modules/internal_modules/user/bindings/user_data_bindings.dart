import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';

class UserDataBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<UserDataController>(UserDataController(), permanent: true);
    Get.put<ExternalModulesServices>(
      ExternalModulesServices(),
      permanent: true,
    );
  }
}
