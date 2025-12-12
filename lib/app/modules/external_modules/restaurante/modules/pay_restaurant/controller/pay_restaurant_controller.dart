import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/repository/pay_restaurant_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/message_dialogs.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class PayRestaurantController extends GetxController {
  PayRestaurantController();

  PayRestaurantRepository payRestaurantRepository = PayRestaurantRepository();

  RxBool isLoading = false.obs;
  RxBool isPaymentProcessing = false.obs;

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
    Get.toNamed(Routes.PAY_RESTAURANT_HELP);
  }

  Future<void> goToPaymentTicket() async {
    isPaymentProcessing.value = true;
    String userAcessToken =
        await externalModulesServices.getAccessToken() ?? "";

    try {
      Map<String, dynamic> paymentCode = await payRestaurantRepository
          .getPaymentCode(userIdUFF, userAcessToken);
    } catch (e) {
      print(e);
      if (e is Exception && e.toString().isNotEmpty) {
        await MessageDialogs.showErrorDialog(
          Get.context,
          message: e.toString(),
        );
      } else {
        await MessageDialogs.showErrorDialog(Get.context);
      }
    }

    isPaymentProcessing.value = false;
  }
}
