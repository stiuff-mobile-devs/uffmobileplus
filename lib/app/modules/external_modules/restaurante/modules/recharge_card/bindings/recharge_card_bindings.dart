import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/controller/recharge_card_controller.dart';

class RechargeCardBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RechargeCardController>(() => RechargeCardController());
  }
}
