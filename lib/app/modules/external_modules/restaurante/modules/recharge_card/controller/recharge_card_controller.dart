import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/message_dialogs.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/data/repository/recharge_card_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:url_launcher/url_launcher.dart';

class RechargeCardController extends GetxController {
  RechargeCardController();

  late ExternalModulesServices externalModulesServices;
  RechargeCardRepository rechargeCardRepository = RechargeCardRepository();
  late final AuthGoogleService _authGoogle = AuthGoogleService();

  RxBool isLoading = false.obs;

  /// Quantidade de botões rápidos (1 a 10 refeições).
  static const int quickOptions = 10;

  RxList<bool> selectedValues = RxList<bool>.filled(quickOptions, false);

  /// Contador de refeições avulsas (começa em 10).
  RxInt mealCount = 10.obs;

  // ── Valor por perfil (só exibição) ────────────────────────────────────

  /// Perfil do usuário, para o painel do topo.
  final Rxn<ProfileTypes> profileType = Rxn<ProfileTypes>();

  /// Saldo atual (texto do servidor) e seu carregamento. Não bloqueia a tela.
  final RxString currentBalance = "".obs;
  final RxBool isBalanceLoading = false.obs;

  /// Valor por refeição usado na grade e no contador. Começa no valor do
  /// perfil; o usuário pode trocar no seletor (0,70 / 14,50).
  final RxDouble selectedPrice = MealPrices.student.obs;

  double? get profilePrice => MealPrices.priceFor(profileType.value);
  double? get balanceValue => MealPrices.parseBalance(currentBalance.value);

  static final NumberFormat _brl = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  String _formatValue(double value) => _brl.format(value).trim();

  /// Valores dos botões rápidos: 1 a 10 refeições no preço selecionado.
  List<String> get textPrices => List.generate(
        quickOptions,
        (i) => _formatValue((i + 1) * selectedPrice.value),
      );

  String get mealCountPrice =>
      _formatValue(mealCount.value * selectedPrice.value);

  void setSelectedPrice(double price) {
    if (selectedPrice.value == price) return;
    selectedPrice.value = price;
    _clearGridSelection();
    priceFieldController.clear();
  }

  void incrementMealCount() {
    mealCount.value++;
    _applyMealCountToField();
    _clearGridSelection();
  }

  void decrementMealCount() {
    if (mealCount.value > 1) {
      mealCount.value--;
      _applyMealCountToField();
      _clearGridSelection();
    }
  }

  void selectMealCountButton() {
    _clearGridSelection();
    _applyMealCountToField();
  }

  void _applyMealCountToField() {
    priceFieldController.text = mealCountPrice;
    priceFieldController.selection = TextSelection.fromPosition(
      TextPosition(offset: priceFieldController.text.length),
    );
  }

  void _clearGridSelection() {
    for (int j = 0; j < selectedValues.length; j++) {
      selectedValues[j] = false;
    }
    selectedValues.refresh();
  }

  TextEditingController priceFieldController = TextEditingController();

  String paymentUrl = "";
  String userIdUFF = "";

  @override
  Future<void> onInit() async {
    super.onInit();
    externalModulesServices = Get.find<ExternalModulesServices>();
    await externalModulesServices.initialize();
    userIdUFF = externalModulesServices.getUserIdUFF();

    profileType.value = externalModulesServices.getUserProfileType();
    selectedPrice.value = profilePrice ?? MealPrices.student;

    _loadBalance();
  }

  Future<void> _loadBalance() async {
    isBalanceLoading.value = true;
    try {
      final token = await externalModulesServices.getAccessToken() ?? "";
      final balance =
          await rechargeCardRepository.getUserBalance(userIdUFF, token);
      currentBalance.value = balance.currentBalance ?? "";
    } catch (e) {
      debugPrint('Erro ao carregar saldo na recarga: $e');
      currentBalance.value = "";
    } finally {
      isBalanceLoading.value = false;
    }
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
    for (int j = 0; j < selectedValues.length; j++) {
      selectedValues[j] = false;
    }
    selectedValues[i] = true;
    selectedValues.refresh();

    priceFieldController.text = textPrices[i];
    priceFieldController.selection = TextSelection.fromPosition(
      TextPosition(offset: priceFieldController.text.length),
    );
  }

  /// Valor digitado/selecionado em reais ("1.234,56" → 1234.56).
  double get _fieldAmount =>
      double.tryParse(
        priceFieldController.text
            .trim()
            .replaceAll('.', '')
            .replaceAll(',', '.'),
      ) ??
      0;

  void goToPayment() async {
    if (_fieldAmount <= 0) {
      AppPopups.warning('recarga_valor_vazio'.tr);
      return;
    }

    isLoading.value = true;
    String userAcessToken =
        await externalModulesServices.getAccessToken() ?? "";
    try {
      paymentUrl = await rechargeCardRepository.getPaymentUrl(
        priceFieldController.text,
        userIdUFF,
        userAcessToken,
        await _authGoogle.getFirebaseIdToken() ?? "",
      );
    } catch (e) {
      debugPrint('Erro ao gerar link de recarga: $e');
      await MessageDialogs.showErrorDialog(
        Get.context,
        title: 'recarga_erro_titulo'.tr,
        message: 'msg_verifique_internet'.tr,
      );
    } finally {
      isLoading.value = false;
    }
    Get.toNamed(Routes.RECHARGE_CARD_PAY);
  }

  void launchPaymentUrl(String url, BuildContext context) async {
    final uri = Uri.tryParse(url);

    if (uri != null && url.isNotEmpty && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) Navigator.pop(context);
    } else {
      debugPrint('Não foi possível abrir o link de recarga: $url');
      AppPopups.error('recarga_link_erro'.tr);
    }
  }
}
