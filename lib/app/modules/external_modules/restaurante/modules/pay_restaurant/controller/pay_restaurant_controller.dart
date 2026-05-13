import 'dart:async';

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
  RxBool isExpired = false.obs;
  RxInt remainingTime = 0.obs;

  late ExternalModulesServices externalModulesServices;

  String userName = "";
  String userIdUFF = "";
  String userImageUrl = "";
  RxString currentBalance = "".obs;
  Map<String, dynamic> paymentCode = {};

  @override
  onInit() {
    externalModulesServices = Get.find<ExternalModulesServices>();
    externalModulesServices.initialize();

    userName = externalModulesServices.getUserName() ?? "";
    userIdUFF = externalModulesServices.getUserIdUFF();
    userImageUrl = externalModulesServices.getUserPhotoUrl();

    getUserBalance();

    super.onInit();
  }

  void goToPaymentHelpScreen() {
    Get.toNamed(Routes.PAY_RESTAURANT_HELP);
  }

  Future<void> goToPaymentTicket() async {
    isPaymentProcessing.value = true;
    isLoading.value = true;
    String userAcessToken =
        await externalModulesServices.getAccessToken() ?? "";

    try {
      paymentCode = await payRestaurantRepository.getPaymentCode(
        userIdUFF,
        userAcessToken,
      );
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
    } finally {
      isPaymentProcessing.value = false;
      isLoading.value = false;
    }
    if (paymentCode.isNotEmpty) {
      qrCodeTimer();
      isLoading.value = false;
      Get.toNamed(Routes.PAY_RESTAURANT_TICKET);
    }
  }

  void qrCodeTimer() {
    late Timer expirationTimer;
    isExpired.value = false;

    final validity = paymentCode["validade"];
    remainingTime.value = validity is int ? validity : 0;

    expirationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.value < 1) {
        timer.cancel();
        isExpired.value = true;
      } else {
        remainingTime.value = remainingTime.value - 1;
      }
    });
  }

  void refresh() {
    isLoading.value = true;
    goToPaymentTicket();
  }

  void getUserBalance() async {
    isLoading.value = true;
    String userAcessToken =
        await externalModulesServices.getAccessToken() ?? "";

    try {
      var userBalance = await Future.wait([
        payRestaurantRepository.getUserBalance(userIdUFF, userAcessToken),
      ]);
      currentBalance.value = userBalance[0].currentBalance ?? "Erro";
    } catch (e) {
      currentBalance.value = "Erro";
    } finally {
      isLoading.value = false;
    }
  }
}
