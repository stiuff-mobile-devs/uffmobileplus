import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/controller/pay_restaurant_controller.dart';

class PayRestaurantBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<PayRestaurantController>(
      PayRestaurantController(),
      permanent: true,
    );
  }
}
