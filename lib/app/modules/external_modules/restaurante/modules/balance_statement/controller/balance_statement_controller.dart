import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/data/repository/balance_statement_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/card_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/constants.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

/// Filtro de tipo do extrato.
enum StatementFilter { all, credit, debit }

class BalanceStatementController extends GetxController {
  BalanceStatementController();

  late final AuthGoogleService _authGoogle = AuthGoogleService();

  BalanceStatementRepository repository = BalanceStatementRepository();
  late ExternalModulesServices externalModulesServices;

  RxBool isBusy = false.obs;

  /// A última busca do extrato falhou.
  final RxBool hasError = false.obs;

  RxMap<String, dynamic> filters = <String, dynamic>{"period": 15.0}.obs;

  /// Opções de período (dias), os mesmos passos do slider antigo.
  static const List<double> periodOptions = [15, 30, 45, 60, 75, 90];

  final Rx<StatementFilter> typeFilter = StatementFilter.all.obs;

  UserBalance userBalance = UserBalance();

  RxString userIduff = ''.obs;
  RxString userName = ''.obs;

  /// Perfil, só para exibir o valor da refeição no painel.
  final Rxn<ProfileTypes> profileType = Rxn<ProfileTypes>();

  double get period => (filters["period"] as num).toDouble();

  double? get mealPrice => MealPrices.priceFor(profileType.value);

  double? get balanceValue => hasError.value
      ? null
      : MealPrices.parseBalance(userBalance.currentBalance ?? '');

  bool get isBalanceInsufficient =>
      MealPrices.isInsufficient(balanceValue, mealPrice);

  /// Extrato filtrado pelo tipo escolhido.
  List<CardTransaction> get filteredStatement {
    final all = userBalance.statement ?? <CardTransaction>[];
    switch (typeFilter.value) {
      case StatementFilter.all:
        return all;
      case StatementFilter.credit:
        return all
            .where((t) => t.category?.contains(Constants.CREDIT) ?? false)
            .toList();
      case StatementFilter.debit:
        return all
            .where((t) => t.category?.contains(Constants.DEBIT) ?? false)
            .toList();
    }
  }

  @override
  Future<void> onInit() async {
    externalModulesServices = Get.find<ExternalModulesServices>();
    await externalModulesServices.initialize();

    userIduff.value = externalModulesServices.getUserIdUFF();
    userName.value = externalModulesServices.getUserName() ?? '';
    profileType.value = externalModulesServices.getUserProfileType();

    getUserBalance();
    super.onInit();
  }

  Future<void> getUserBalance() async {
    isBusy.value = true;
    hasError.value = false;
    try {
      String userAcessToken =
          await externalModulesServices.getAccessToken() ?? "";
      await repository.fetchUserBalance(
        userIduff.value,
        userAcessToken,
        await _authGoogle.getFirebaseIdToken() ?? "",
      );
      userBalance = await repository.getUserBalance(
        userIduff.value,
        userAcessToken,
        await _authGoogle.getFirebaseIdToken() ?? "",
        period: filters["period"],
      );
    } catch (e) {
      debugPrint("Erro ao obter o extrato do usuário: $e");
      hasError.value = true;
    } finally {
      isBusy.value = false;
    }
  }

  void setPeriod(double days) {
    if (days == period) return;
    filters["period"] = days;
    getUserBalance();
  }

  void setTypeFilter(StatementFilter filter) => typeFilter.value = filter;

  void goToRecharge() => Get.toNamed(Routes.RECHARGE_CARD);
}
