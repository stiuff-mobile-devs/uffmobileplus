import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/screen_protector_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/repository/pay_restaurant_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/message_dialogs.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class PayRestaurantController extends GetxController {
  PayRestaurantController();

  PayRestaurantRepository payRestaurantRepository = PayRestaurantRepository();
   late final AuthGoogleService _authGoogle = AuthGoogleService();

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

  /// Perfil do usuário, usado só para exibir o valor da refeição.
  final Rxn<ProfileTypes> profileType = Rxn<ProfileTypes>();

  /// Valor por refeição mostrado no painel. Começa no valor do perfil; o
  /// usuário pode trocar no seletor (0,70 / 14,50). Só muda a visualização.
  final RxDouble selectedPrice = MealPrices.student.obs;

  /// TESTE: mostra o botão de recarga sempre, para conferir o visual.
  /// Voltar para `false` (regra final: aparece com saldo menor que uma
  /// refeição).
  bool forceShowRechargeButton = false;

  ScreenProtectorService screenProtector = ScreenProtectorService();

  @override
  onInit() {

    externalModulesServices = Get.find<ExternalModulesServices>();
    externalModulesServices.initialize();

    screenProtector.enableScreenProtection();

    userName = externalModulesServices.getUserName() ?? "";
    userIdUFF = externalModulesServices.getUserIdUFF();
    userImageUrl = externalModulesServices.getUserPhotoUrl() ?? "";

    _loadProfile();
    getUserBalance();

    super.onInit();
  }

  /// Rebusca saldo e perfil (botão de atualizar da tela).
  void reloadData() {
    _loadProfile();
    getUserBalance();
  }

  Future<void> _loadProfile() async {
    // Garante o usuário salvo carregado antes de ler o perfil.
    await externalModulesServices.initialize();
    profileType.value = externalModulesServices.getUserProfileType();
    selectedPrice.value = mealPrice ?? MealPrices.student;
  }

  void setSelectedPrice(double price) => selectedPrice.value = price;

  /// O valor mostrado é diferente do valor do perfil (modo simulação).
  bool get isSimulating =>
      mealPrice != null && selectedPrice.value != mealPrice;


  /// Valor da refeição do perfil; `null` se o perfil não come no RU.
  double? get mealPrice => MealPrices.priceFor(profileType.value);

  /// Saldo como número; `null` se não foi possível carregar.
  double? get balanceValue => MealPrices.parseBalance(currentBalance.value);

  /// Quantas refeições o saldo paga no valor do perfil.
  int? get mealsAvailable => MealPrices.mealsFor(balanceValue, mealPrice);

  /// Saldo zerado/negativo ou menor que o valor de uma refeição, no valor
  /// escolhido no seletor (acompanha a visualização, como o painel).
  bool get isBalanceInsufficient =>
      MealPrices.isInsufficient(balanceValue, selectedPrice.value);

  bool get showRechargeButton =>
      forceShowRechargeButton || isBalanceInsufficient;

  void goToRecharge() {
    Get.toNamed(Routes.RECHARGE_CARD);
  }

  void goToPaymentHelpScreen() {
    Get.toNamed(Routes.PAY_RESTAURANT_HELP);
  }

  Future<void> goToPaymentTicket() async {
    _setMaxBrightness();
    isPaymentProcessing.value = true;
    isLoading.value = true;
    String userAcessToken =
        await externalModulesServices.getAccessToken() ?? "";

    try {
      paymentCode = await payRestaurantRepository.getPaymentCode(
        userIdUFF,
        userAcessToken,
        await _authGoogle.getFirebaseIdToken() ?? "",
      );
    } catch (e) {
      debugPrint('Erro ao gerar código de pagamento: $e');
      // O servidor costuma explicar o motivo (lançado como Exception(texto)).
      // Mostra só esse texto, sem o prefixo "Exception: "; erros de rede ou
      // outros detalhes técnicos viram uma mensagem genérica.
      final raw = e.toString();
      final serverMessage = raw.startsWith('Exception: ')
          ? raw.substring('Exception: '.length).trim()
          : '';
      await MessageDialogs.showErrorDialog(
        Get.context,
        title: 'pagamento_erro_titulo'.tr,
        message: serverMessage.isNotEmpty
            ? serverMessage
            : 'msg_verifique_internet'.tr,
      );
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
  
  Future<void> _setMaxBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e) {
      // Alguns dispositivos ou plataformas podem recusar a alteração
      debugPrint('Erro ao aumentar brilho da tela: $e');
    }
  }

  @override
  void onClose() {
    ScreenBrightness().resetApplicationScreenBrightness();
    screenProtector.disableScreenProtection();
    super.onClose();
  }
}
