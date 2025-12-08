import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';

class PayRestaurantController extends GetxController {
  PayRestaurantController();

  RxBool isLoading = false.obs;
  late ExternalModulesServices externalModulesServices;

  String userName = "";
  String userIdUFF = "";
  String userImageUrl = "";
  String currentBalance = "";

  @override
  onInit() {
    externalModulesServices = Get.find<ExternalModulesServices>();
    externalModulesServices.initialize();

    userName = externalModulesServices.getUserName() ?? "";
    userIdUFF = externalModulesServices.getUserIdUFF();
    userImageUrl = externalModulesServices.getUserPhotoUrl();

    super.onInit();
  }

  void goToPaymentHelpScreen() {
    Get.toNamed('/restaurante/pay_restaurant/help');
  }

  void goToPaymentTicket() {
    Get.toNamed('/restaurante/pay_restaurant/ticket');
  }
}
