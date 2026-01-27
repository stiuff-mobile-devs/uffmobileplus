import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_iduff_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class SettingsController extends GetxController {
  SettingsController();

  late final UserIduffController _userIduffController;
  late final LoginController _loginController;
  late final AuthGoogleController _authGoogleController;
  late final UserDataController _userDataController;

  late RxBool hasActiveIduffBondObs;
  late RxBool hasActiveGoogleBondObs;

  @override
  onInit() {
    _userIduffController = Get.find<UserIduffController>();
    _loginController = Get.find<LoginController>();
    _authGoogleController = Get.find<AuthGoogleController>();
    _userDataController = Get.find<UserDataController>();

    hasActiveIduffBondObs = _loginController.hasActiveIduffBondObs;
    hasActiveGoogleBondObs = _loginController.hasActiveGoogleBondObs;
    super.onInit();
  }

  void logoutIduff() {
    _userIduffController.deleteUserIduffModel();
    _loginController.logoutGoogle();
    _userDataController.clearAllUserData();
    Get.offAllNamed(Routes.LOGIN);
  }

  void changeMatricula() async {
    String? iduff = await _userIduffController.getIduff();
    Get.offAllNamed(Routes.CHOOSE_PROFILE, arguments: iduff);
  }

  Future<void> reloadBondStates() async {
    await _loginController.reloadBondStates();
  }

  void handleIduffBondTap() async {
    if (hasActiveIduffBondObs.value) {
      _showIduffLogoutConfirmation();
    } else {
      _showIduffLoginConfirmation();
    }
  }

  void handleGoogleBondTap() async {
    if (hasActiveGoogleBondObs.value) {
      _showGoogleLogoutConfirmation();
    } else {
      _showGoogleLoginConfirmation();
    }
  }

  void _showIduffLoginConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Login IdUFF',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Você será redirecionado para fazer login com sua conta IdUFF. Sua matrícula será vinculada a este dispositivo.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _loginController.loginIDUFF();
            },
            child: Text(
              'Continuar',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showIduffLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Desconectar IdUFF',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Sua conta IdUFF será desconectada deste dispositivo. Você perderá acesso aos serviços que requerem autenticação.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logoutIduff();
            },
            child: Text(
              'Desconectar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showGoogleLoginConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Login Google',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Você será redirecionado para fazer login com sua conta Google. Sua conta será vinculada a este dispositivo.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _loginController.loginGoogle();
            },
            child: Text('Continuar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showGoogleLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Desconectar Google',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Sua conta Google será desconectada deste dispositivo. Você perderá acesso aos serviços vinculados a esta autenticação.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _authGoogleController.logout();
            },
            child: Text(
              'Desconectar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
