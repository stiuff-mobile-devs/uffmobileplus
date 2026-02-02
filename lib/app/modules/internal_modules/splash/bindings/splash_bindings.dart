import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/splash/controller/splash_controller.dart';

class SplashBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<UmInfosService>(UmInfosService(), permanent: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
