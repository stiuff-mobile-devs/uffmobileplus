import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/message_dialogs.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/data/repository/recharge_card_repository.dart';

class RechargeCardController extends GetxController {
  RechargeCardController();

  late ExternalModulesServices externalModulesServices;
  RechargeCardRepository rechargeCardRepository = RechargeCardRepository();

  RxBool isLoading = false.obs;

  RxList<bool> selectedValues = RxList<bool>.filled(10, false);

  RxList<String> textPrices = RxList<String>.from([
    "0,70",
    "1,40",
    "2,10",
    "2,80",
    "3,50",
    "4,20",
    "4,90",
    "5,60",
    "6,30",
    "7,00",
  ]);

  TextEditingController priceFieldController = TextEditingController();

  String paymentUrl = "";
  String userIdUFF = "";

  @override
  Future<void> onInit() async {
    externalModulesServices = ExternalModulesServices();
    await externalModulesServices.initialize();
    userIdUFF = externalModulesServices.getUserIdUFF();

    super.onInit();
  }

  void formatCurrency() {
    NumberFormat numberFormat = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "",
      decimalDigits: 2,
    );

    priceFieldController.text = numberFormat.format(
      double.parse(priceFieldController.text.replaceAll(',', '.')),
    );
    priceFieldController.selection = TextSelection.fromPosition(
      TextPosition(offset: priceFieldController.text.length),
    );
  }

  void setSelectedValue(int i) {
    // Use .value para modificar a RxList reativa
    for (int j = 0; j < selectedValues.length; j++) {
      selectedValues[j] = false;
    }
    selectedValues[i] = true;
    selectedValues.refresh(); // Força a atualização

    priceFieldController.text = textPrices[i];
    priceFieldController.selection = TextSelection.fromPosition(
      TextPosition(offset: priceFieldController.text.length),
    );
  }

  void goToPayment() async {
    String userAcessToken =
        await externalModulesServices.getAccessToken() ?? "";
    try {
      paymentUrl = await rechargeCardRepository.getPaymentUrl(
        priceFieldController.text,
        userIdUFF,
        userAcessToken,
      );
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      await MessageDialogs.showErrorDialog(Get.context);
    }
  }
}
