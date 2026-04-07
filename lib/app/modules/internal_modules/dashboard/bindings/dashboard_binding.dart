import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/settings_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ExternalModulesServices>()) {
      Get.put<ExternalModulesServices>(
        ExternalModulesServices(),
        permanent: true,
      );
    }

    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ExternalModulesController>(() => ExternalModulesController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<HomePageController>(() => HomePageController());
  }
}
