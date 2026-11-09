import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
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
     loginController.logoutGoogle();
  }

  Future<void> logoutIduff() async {
    await _userDataRepository.deleteUserIduffModel();
    Get.offAllNamed(Routes.LOGIN);
  }

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
    } catch (e) {
      debugPrint('Erro ao atualizar dados do Google: $e');
      AppPopups.error(
        'erro_atualizar_dados_google_msg'.tr,
        title: 'erro_atualizar_dados_google'.tr,
      );
    }
  }

  Future<void> _showIduffLoginConfirmation() async {
    final ok = await AppPopups.confirm(
      title: 'login_iduff_titulo'.tr,
      message: 'login_iduff_confirmacao_msg'.tr,
      icon: Icons.login_rounded,
      confirmText: 'continuar'.tr,
    );
    if (ok) loginController.loginIDUFF();
  }

  Future<void> _showIduffLogoutConfirmation() async {
    final ok = await AppPopups.confirm(
      title: 'desconectar_iduff_titulo'.tr,
      message: 'desconectar_iduff_confirmacao_msg'.tr,
      icon: Icons.link_off_rounded,
      confirmText: 'desconectar'.tr,
      destructive: true,
    );
    if (ok) await logoutIduff();
  }

  Future<void> _showGoogleLoginConfirmation() async {
    final ok = await AppPopups.confirm(
      title: 'login_google_titulo'.tr,
      message: 'login_google_confirmacao_msg'.tr,
      icon: Icons.login_rounded,
      confirmText: 'continuar'.tr,
    );
    if (ok) loginController.loginGoogle();
  }

  Future<void> _showGoogleLogoutConfirmation() async {
    final ok = await AppPopups.confirm(
      title: 'desconectar_google_titulo'.tr,
      message: 'desconectar_google_confirmacao_msg'.tr,
      icon: Icons.link_off_rounded,
      confirmText: 'desconectar'.tr,
      destructive: true,
    );
    if (ok) _authGoogleController.logout();
  }
}
