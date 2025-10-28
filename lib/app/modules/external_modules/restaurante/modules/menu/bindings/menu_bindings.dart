import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/controller/details_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/controller/meal_form_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/controller/restaurants_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/controller/menu_controller.dart';
import '../../../../../../data/services/external_menu_service.dart';

class MenuBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<ExternalMenuService>(ExternalMenuService(), permanent: true);
    Get.put<RestaurantsController>(RestaurantsController());
    Get.put<MenuController>(MenuController());
    Get.put<MenuListController>(MenuListController());
    Get.put<MealFormController>(MealFormController());
    Get.put<DetailsController>(DetailsController());
  }
}