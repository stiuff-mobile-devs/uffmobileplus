import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/data/services/google_drive_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/data/services/harpia_claims_service.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class AuthGoogleController extends GetxController {
  AuthGoogleController();

  late final AuthGoogleService _authGoogle = AuthGoogleService();
  late final UserDataRepository _userDataRepository = UserDataRepository();

  @override
  void onInit() {
    super.onInit();
  }

  AuthGoogleService get authGoogle => _authGoogle;

  /// Login interativo. Retorna o usuário quando o login foi concluído, ou
  /// `null` se falhou, foi cancelado ou o e-mail não institucional foi recusado.
  ///
  /// Com [navigate] falso (login pelas Configurações), não troca de tela: quem
  /// chamou decide para onde ir e recarrega a dashboard.
  Future<UserGoogleModel?> loginGoogle({bool navigate = true}) async {
    try {
      UserGoogleModel? user = await _authGoogle.signInGoogle();

      if (user != null) {
        final previousEmail =
            (await _userDataRepository.getUserGoogleModel())?.email?.toLowerCase();
        String? token = await _authGoogle.getFirebaseIdToken();
        await _userDataRepository.saveUserGoogleModel(user);
        // Grupos de outra conta não servem: limpa para a regra dos 90 dias
        // buscar de novo (ex.: sessão expirou e entrou com outra conta).
        if (previousEmail != null &&
            previousEmail.isNotEmpty &&
            previousEmail != user.email?.toLowerCase()) {
          await _userDataRepository.clearGdiGroupsGoogle();
        }
        await _registerTokenCdc();
        await getGdiGroupsGoogle(token ?? '', user.email ?? "", false);

        // Sincronizar Custom Claims do Harpia
        HarpiaClaimsService.syncClaims();

        if (!await _confirmInstitutionalEmail(user.email ?? "")) {
          // Desloga para o usuário poder escolher outra conta do Google
          if (navigate) {
            await logout();
          } else {
            await _clearGoogleSession();
          }
          return null;
        }

        unawaited(_ensureDriveFolder(interactive: true));
        if (navigate) Get.offAllNamed(Routes.HOME);
        return user;
      } else {
        AppPopups.hideLoading();
        AppPopups.error(
          'falha_autenticar_usuario'.tr,
          title: 'erro_login_titulo'.tr,
        );
        return null;
      }
    } catch (e) {
      debugPrint('Erro no login Google: $e');
      AppPopups.hideLoading();
      AppPopups.error(
        'erro_login_google_msg'.tr,
        title: 'erro_login_externo_titulo'.tr,
      );
      rethrow;
    }
  }

  /// E-mail @id.uff.br passa direto; outro e-mail pede confirmação.
  Future<bool> _confirmInstitutionalEmail(String email) async {
    if (email.endsWith('@id.uff.br')) return true;

    // O aviso precisa ficar acessível, então fecha um carregamento aberto
    // (não faz nada se não houver).
    AppPopups.hideLoading();
    return AppPopups.confirm(
      title: 'aviso_email_nao_institucional_titulo'.tr,
      message: 'aviso_email_nao_institucional_msg'.tr,
      icon: Icons.alternate_email_rounded,
      type: PopupType.warning,
      confirmText: 'continuar'.tr,
      cancelText: 'refazer_login'.tr,
      dismissible: false,
    );
  }

  Future<bool> tryLogin({bool navigate = true}) async {
    UserGoogleModel? hasLogged = await _authGoogle.trySignInGoogle();
    if (hasLogged != null) {
      await _registerTokenCdc();
      String? token = await _authGoogle.getFirebaseIdToken();
      await getGdiGroupsGoogle(token ?? '', hasLogged.email ?? "", false);
      HarpiaClaimsService.syncClaims();
      unawaited(_ensureDriveFolder(interactive: false));
      if (navigate) Get.offAllNamed(Routes.HOME);
      return true;
    } else {
      return false;
    }
  }

  // Garante a pasta do app no Google Drive. Não bloqueia a navegação
  Future<void> _ensureDriveFolder({required bool interactive}) async {
    try {
      await GoogleDriveService().ensureFolderExists(interactive: interactive);
    } catch (e) {
      debugPrint('Erro ao garantir pasta no Drive: $e');
    }
  }

  Future<void> logout() async {
    await _clearGoogleSession();
    Get.offAllNamed(Routes.LOGIN);
  }

  /// Sai da conta Google e apaga o que é dela (usuário e grupos GDI), sem navegar.
  Future<void> _clearGoogleSession() async {
    await _authGoogle.logoutGoogle();
    await _userDataRepository.deleteUserGoogleModel();
    await _userDataRepository.clearGdiGroupsGoogle();
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
      
      GdiGroupsGoogle gdiGroups = await _userDataRepository.getGdiGroupsGoogle(
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

      bool isSameMethod = user.lastRegisteredTokenCdcMethod == 'google';
      bool isRecent = user.lastRegisteredTokenCdcUpdate != null &&
          DateTime.now()
                  .difference(user.lastRegisteredTokenCdcUpdate as DateTime)
                  .inDays <
              90;

      if (isSameMethod && isRecent) {
        debugPrint(
          "Token CDC já atualizado recentemente para login Google. Não é necessário atualizar.",
        );
        return;
      }

      bool isAndroid = Platform.isAndroid;
      String device = isAndroid ? 'android' : 'ios';
      String? tokenDevice = await getTokenDevice(isAndroid);
      String? token = await _authGoogle.getFirebaseIdToken();

      if (token != null && tokenDevice != null) {
        bool success = await _userDataRepository.registerTokenCdc(token, tokenDevice, device);
        if (success) {
          await _userDataRepository.lastRegisteredTokenCdcUpdate(
            DateTime.now(),
            'google',
          );
        }
      }
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
