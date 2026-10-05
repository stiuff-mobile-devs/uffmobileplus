import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/data/repository/balance_statement_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';

class BalanceStatementController extends GetxController {
  BalanceStatementController();

   late final AuthGoogleService _authGoogle = AuthGoogleService();
   
  BalanceStatementRepository repository = BalanceStatementRepository();
  late ExternalModulesServices externalModulesServices;

  RxBool isBusy = false.obs;
  
  RxBool isFiltersOpen = false.obs;
  RxMap<String, dynamic> filters = <String, dynamic>{"period": 15.0}.obs;
  RxMap<String, dynamic> filterSlider = <String, dynamic>{"period": 15.0}.obs;
  
  UserBalance userBalance = UserBalance();

  RxString userIduff = ''.obs;
  RxString userName = ''.obs;

  @override
  Future<void> onInit() async {
    externalModulesServices = Get.find<ExternalModulesServices>();
    await externalModulesServices.initialize();

    userIduff.value = externalModulesServices.getUserIdUFF();
    userName.value = externalModulesServices.getUserName() ?? '';

    getUserBalance();
    super.onInit();
  }

  void getUserBalance() async {
    isBusy.value = true;
    String userAcessToken =
        await externalModulesServices.getAccessToken() ?? "";
    await repository.fetchUserBalance(userIduff.value, userAcessToken, await _authGoogle.getFirebaseIdToken() ?? "");
    try {
      userBalance = await repository.getUserBalance(
        userIduff.value,
        userAcessToken,
        await _authGoogle.getFirebaseIdToken() ?? "",
        period: filters["period"],
      );
    } catch (e) {
      print("Erro ao obter o extrato do usuário: $e");
    } finally {
      isBusy.value = false;
    }
  }

  void openFilters() {
    isFiltersOpen.value = true;
  }

  void closeFilters() {
    isFiltersOpen.value = false;
    filterSlider["period"] = filters["period"];
  }

  void applyFilters(BuildContext context) {
    isFiltersOpen.value = false;
    filters["period"] = filterSlider["period"];
    getUserBalance();
  }

  void resetFilters() {
    filters["period"] = 15.0;
    filterSlider["period"] = 15.0;
    getUserBalance();
  }

  void changePeriod(double value) {
    filterSlider["period"] = value;
  }
}