import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/choose_profile/controller/choose_profile_controller.dart';

class ChooseProfileBindings implements Bindings {
@override
void dependencies() {
  Get.lazyPut<ChooseProfileController>(() => ChooseProfileController());
  }
}