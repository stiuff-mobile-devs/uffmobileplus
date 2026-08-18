import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class AuthGoogleController extends GetxController {
  AuthGoogleController();

  late final AuthGoogleService _authGoogle = AuthGoogleService();
  late final UserGoogleRepository _userRepository = UserGoogleRepository();
  late final UserDataRepository _userDataRepository = UserDataRepository();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loginGoogle() async {
    try {
      UserGoogleModel? user = await _authGoogle.signInGoogle();

      if (user != null) {
        String? token = await _authGoogle.getFirebaseIdToken();
        await _userRepository.saveUserGoogleModel(user);
        await _registerTokenCdc();
        await getGdiGroupsGoogle(token ?? '', user.email, false);
        
        // Chama a função auxiliar passando o e-mail
        _verifyEmailAndNavigate(user.email);

      } else {
        Get.snackbar(
          "Erro de Login",
          "Falha ao autenticar o usuário.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erro de Login externo",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  void _verifyEmailAndNavigate(String email) {
    if (email.endsWith('@id.uff.br')) {
      // Se for acadêmico, vai direto para a Home
      Get.offNamed(Routes.HOME);
    } else {
      // Se não for, exibe o pop-up
      Get.defaultDialog(
        title: "Atenção",
        middleText: "Você não entrou com um e-mail institucional (@id.uff.br). Algumas funcionalidades podem estar indisponíveis.\n\nDeseja continuar mesmo assim?",
        textConfirm: "Continuar",
        textCancel: "Refazer Login",
        confirmTextColor: Colors.white,
        barrierDismissible: false,
        onConfirm: () {
          Get.back(); // Fecha o dialog
          Get.offNamed(Routes.HOME); // Vai para a Home
        },
        onCancel: () async {
          // Desloga o usuário para ele poder escolher outra conta do Google
          logout();
          debugPrint("Usuário cancelou. Inserir lógica de logout aqui.");
        },
      );
    }
  }

  tryLogin() async {
    UserGoogleModel? hasLogged = await _authGoogle.trySignInGoogle();
    if (hasLogged != null) {
      await _registerTokenCdc();
      String? token = await _authGoogle.getFirebaseIdToken();
      await getGdiGroupsGoogle(token ?? '', hasLogged.email, false);
      Get.offNamed(Routes.HOME);
    } else {
      Get.offNamed(Routes.LOGIN);
    }
  }

  Future<void> logout() async {
    await _authGoogle.logoutGoogle();
    await _userRepository.deleteUserGoogleModel();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> getGdiGroupsGoogle(String token, String email, bool forceUpdate) async {
    try {
      UserData user = await _userDataRepository.getUserData() ?? UserData();
      if(!forceUpdate){
        if (user.gdiGroupsGoogle != null &&
          user.gdiGroupsGoogle?.lastUpdate != null) {
        if (DateTime.now()
                .difference(user.gdiGroupsGoogle?.lastUpdate as DateTime)
                .inDays <
            90) {
          debugPrint(
            "GDI Groups Google já atualizado recentemente. Não é necessário atualizar.",
          );
          return;
        }
      }
      }
      
      GdiGroupsGoogle gdiGroups = await _userRepository.getGdiGroupsGoogle(
        token,
        email,
      );
      await _userDataRepository.updateGdiGroupsGoogle(gdiGroups);
    } catch (e) {
      debugPrint("Erro ao obter grupos GDI Google: $e");
    }
  }

  Future<void> _registerTokenCdc() async {
    try {
      UserData user = await _userDataRepository.getUserData() ?? UserData();

      if (user.lastRegisteredTokenCdcUpdate != null) {
        if (DateTime.now()
                .difference(user.lastRegisteredTokenCdcUpdate as DateTime)
                .inDays <
            90) {
          debugPrint(
            "Token CDC já atualizado recentemente. Não é necessário atualizar.",
          );
          return;
        }
      }
      bool isAndroid = Platform.isAndroid;
      String device = isAndroid ? 'android' : 'ios';
      String? tokenDevice = await getTokenDevice(isAndroid);
      String? token = await _authGoogle.getFirebaseIdToken();

      if (token != null && tokenDevice != null) {
        await _userRepository.registerTokenCdc(token, tokenDevice, device);
      }

      await _userDataRepository.lastRegisteredTokenCdcUpdate(DateTime.now());
    } catch (e) {
      debugPrint("Erro ao registrar token CDC: $e");
    }
  }

  Future<String?> getTokenDevice(bool isAndroid) async {
    try {
      if (isAndroid) {
        String? token = await FirebaseMessaging.instance.getToken();
        debugPrint("Token Android: $token");
        return token;
      } else {
        FirebaseMessaging messaging = FirebaseMessaging.instance;

        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          String? token = await messaging.getAPNSToken(); // Token da Apple
          String? fcmToken = await messaging.getToken(); // Token do Firebase
          debugPrint("Token FCM (iOS): $fcmToken");
          debugPrint("Token APNs (iOS): $token");
          return token; // Retorna o token do Firebase para iOS
        }
      }
    } catch (e) {
      debugPrint("Erro ao obter token do dispositivo: $e");
      return null;
    }
    return null;
  }

   Future<String?> getFirebaseIdToken() async {
    // Pega o usuário logado atualmente no Firebase
    return await _authGoogle.getFirebaseIdToken();
    
  }
}
