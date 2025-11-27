import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/controller/restaurant_modules_controller.dart';

class RestauranteBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantModulesController>(
      () => RestaurantModulesController(),
    );
  }
}
