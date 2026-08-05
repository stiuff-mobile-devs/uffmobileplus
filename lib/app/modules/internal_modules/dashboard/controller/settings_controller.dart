import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_iduff_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class SettingsController extends GetxController {
  SettingsController();
  UserIduffRepository userIduffRepository = UserIduffRepository();
  UserDataRepository userDataRepository = UserDataRepository();
  UserGoogleRepository userGoogleRepository = UserGoogleRepository();

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
    await userIduffRepository.deleteUserIduffModel();
    await userDataRepository.clearAllUserData();
     loginController.logoutGoogle();
  }

  void changeMatricula() async {
    Get.offAllNamed(Routes.CHOOSE_PROFILE);
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
  Future<void> updateGoogleData() async{
    try{
      final token = await _authGoogleController.getFirebaseIdToken();
      UserGoogleModel? user = await userGoogleRepository.getUserGoogleModel();
      await _authGoogleController.getGdiGroupsGoogle(token!, user!.email, true);
    }
    catch(e){
      Get.snackbar(
        "Erro ao atualizar dados do Google",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
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
              loginController.loginIDUFF();
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
              logout();
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
              loginController.loginGoogle();
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
