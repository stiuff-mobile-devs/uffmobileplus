import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/details_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/meal_form_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/restaurants_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/menu_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/google_groups_controller.dart';

class CardapioBindings implements Bindings {
  @override
  void dependencies() {
    // Permite abertura direta via deep link sem depender do fluxo da Home.
    if (!Get.isRegistered<UserDataController>()) {
      Get.put<UserDataController>(UserDataController(), permanent: true);
    }
    if (!Get.isRegistered<ExternalModulesServices>()) {
      Get.put<ExternalModulesServices>(ExternalModulesServices(), permanent: true);
    }

    Get.put<RestaurantsController>(RestaurantsController());
    Get.put<MenuController>(MenuController());
    Get.put<MenuListController>(MenuListController());
    Get.put<MealFormController>(MealFormController());
    Get.put<DetailsController>(DetailsController());

    Get.lazyPut(() => CardapioGoogleGroupsController());
  }
}
