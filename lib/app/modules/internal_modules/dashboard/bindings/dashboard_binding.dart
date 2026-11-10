import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/responsive_layout_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/controller/radio_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ExternalModulesServices>()) {
      Get.put<ExternalModulesServices>(
        ExternalModulesServices(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ResponsiveLayoutService>()) {
      Get.put<ResponsiveLayoutService>(
        ResponsiveLayoutService(),
        permanent: true,
      );
    }

    // Player da rádio compartilhado entre o card da Home e a tela da rádio.
    // Permanente para o som não parar quando a rota que o criou fecha.
    if (!Get.isRegistered<RadioController>()) {
      Get.put<RadioController>(RadioController(), permanent: true);
    }

    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ExternalModulesController>(() => ExternalModulesController());
    Get.lazyPut<HomePageController>(() => HomePageController());
  }
}
