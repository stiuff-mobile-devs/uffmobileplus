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

  void loginGoogle() async {
    try {
      UserGoogleModel? user = await _authGoogle.signInGoogle();

      if (user != null) {
        String? token = await _authGoogle.getFirebaseIdToken();
        await _userRepository.saveUserGoogleModel(user);
        await _registerTokenCdc();
        await _getGdiGroupsGoogle(token ?? '', user.email);
        Get.offNamed(Routes.HOME);
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

  tryLogin() async {
    UserGoogleModel? hasLogged = await _authGoogle.trySignInGoogle();
    if (hasLogged != null) {
      await _registerTokenCdc();
      String? token = await _authGoogle.getFirebaseIdToken();
      await _getGdiGroupsGoogle(token ?? '', hasLogged.email);
      Get.offNamed(Routes.HOME);
    } else {
      Get.offNamed(Routes.LOGIN);
    }
  }

  void logout() {
    _authGoogle.logoutGoogle();
    _userRepository.deleteUserGoogleModel();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> _getGdiGroupsGoogle(String token, String email) async {
    GdiGroupsGoogle gdiGroups = await _userRepository.getGdiGroupsGoogle(
      token,
      email,
    );
    UserData userData = UserData(gdiGroupsGoogle: gdiGroups);
    _userDataRepository.saveUserData(userData);
  }

  Future<void> _registerTokenCdc() async {
    bool isAndroid = Platform.isAndroid;
    String device = isAndroid ? 'android' : 'ios';
    String? tokenDevice = await getTokenDevice(isAndroid);
    String? token = await _authGoogle.getFirebaseIdToken();

    if (token != null && tokenDevice != null) {
      await _userRepository.registerTokenCdc(token, tokenDevice, device);
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
}
