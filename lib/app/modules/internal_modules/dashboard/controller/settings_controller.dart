import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/utils/bond_actions.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

class SettingsController extends GetxController {
  SettingsController();
  UserDataRepository _userDataRepository = UserDataRepository();

  late final LoginController loginController;
  late final AuthGoogleController _authGoogleController;


  @override
  onInit() async {
    loginController = Get.find<LoginController>();
    _authGoogleController = Get.find<AuthGoogleController>();
    await reloadBondStates();
    
    super.onInit();
  }

  Future<void> logout() async {
    await _userDataRepository.deleteUserIduffModel();
    await _userDataRepository.clearUserData();
    CrashReporter.clearUser();
     loginController.logoutGoogle();
  }

  /// Explica o que acontece ao sair antes de executar o [logout].
  Future<void> confirmLogout() async {
    final ok = await AppPopups.confirm(
      title: 'sair_confirmacao_titulo'.tr,
      message: 'sair_confirmacao_msg'.tr,
      icon: Icons.logout_rounded,
      confirmText: 'sair'.tr,
      destructive: true,
    );
    if (ok) await logout();
  }

  Future<void> logoutIduff() => BondActions.logoutIduff();

  void changeMatricula() async {
    Get.offAllNamed(Routes.CHOOSE_PROFILE, arguments: {'ask_selection': true});
  }

  Future<void> reloadBondStates() async {
    
    await loginController.reloadBondStates();
    
  }

  void handleIduffBondTap() async {
    await reloadBondStates();
    if (loginController.hasActiveIduffBondObs.value) {
      _showIduffLogoutConfirmation();
    } else {
      _showIduffLoginConfirmation();
    }
  }

  void handleGoogleBondTap() async {
    await reloadBondStates();

    if (loginController.hasActiveGoogleBondObs.value) {
      _showGoogleLogoutConfirmation();
    } else {
      _showGoogleLoginConfirmation();
    }
  }
  Future<void> updateGoogleData() async {
    try {
      final token = await _authGoogleController.getFirebaseIdToken();
      UserGoogleModel? user = await _userDataRepository.getUserGoogleModel();
      await _authGoogleController.getGdiGroupsGoogle(token!, user?.email ?? "", true);
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'atualizar dados do google');
      debugPrint('Erro ao atualizar dados do Google: $e');
      AppPopups.error(
        'erro_atualizar_dados_google_msg'.tr,
        title: 'erro_atualizar_dados_google'.tr,
      );
    }
  }

  Future<void> _showIduffLoginConfirmation() =>
      BondActions.confirmIduffLogin();

  Future<void> _showIduffLogoutConfirmation() =>
      BondActions.confirmIduffLogout();

  Future<void> _showGoogleLoginConfirmation() async {
    final UserGoogleModel? user = await BondActions.confirmGoogleLogin();

    if (user == null) {
      await reloadBondStates();
      return;
    }

    // Volta para a Home que já está aberta (fecha a folha e as Configurações)
    // e recarrega os dados dela com a conta nova.
    if (Get.isRegistered<HomePageController>()) {
      Get.until((route) => route.settings.name == Routes.HOME);
      await Get.find<HomePageController>().reloadSession();
    } else {
      Get.offAllNamed(Routes.HOME);
    }
    final email = user.email ?? '';
    AppPopups.success(
      email.isEmpty
          ? 'login_sucesso_titulo'.tr
          : 'login_google_sucesso_msg'.trParams({'email': email}),
      title: email.isEmpty ? null : 'login_sucesso_titulo'.tr,
    );
  }

  Future<void> _showGoogleLogoutConfirmation() async {
    await BondActions.confirmGoogleLogout();
  }
}
