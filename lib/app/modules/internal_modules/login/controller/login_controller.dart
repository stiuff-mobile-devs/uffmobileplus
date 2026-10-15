import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';

class LoginController extends GetxController {
  bool showQrCode = false;
  late String versionCode;
  late final AuthGoogleController _loginGoogleController;
  late UmInfosService _umInfosService;

  final UserDataRepository _userDataRepository = UserDataRepository();

  UserData _user = UserData();

  RxBool hasAdminPermission = false.obs;
  RxBool hasActiveIduffBondObs = false.obs;
  RxBool hasActiveGoogleBondObs = false.obs;

  RxBool isLoading = false.obs;

  @override
  Future<void> onInit() async {
    _loginGoogleController = Get.find<AuthGoogleController>();
    _umInfosService = Get.find<UmInfosService>();

    versionCode = _umInfosService.version.value;
    _user = (await _userDataRepository.getUserData()) ?? UserData();

    _checkAdminPermission(GdiGroupsEnum.controladoresDeAcesso.id);
    _loadBondStates();
    super.onInit();
  }

  /// Indica se há uma sessão Google que permite login silencioso:
  /// usuário salvo localmente + sessão Firebase persistida e ainda válida no servidor.
  Future<bool> hasActiveGoogleBond() async {
    try {
      final storedUser = await _userDataRepository.getUserGoogleModel();
      final storedEmail = storedUser?.email ?? '';
      if (storedEmail.isEmpty) return false;

      final currentUser = fb.FirebaseAuth.instanceFor(
        app: Firebase.app('uffmobileplus'),
      ).currentUser;
      if (currentUser == null) return false;

      // A sessão do Firebase precisa pertencer à mesma conta salva localmente
      if (currentUser.email?.toLowerCase() != storedEmail.toLowerCase()) {
        return false;
      }

      // Força a renovação do ID token: só funciona se o refresh token do Firebase
      // ainda for válido (usuário não removido/desativado, sessão não revogada).
      // O getIdTokenResult() sem forçar sempre devolve um token já renovado,
      // então checar a data de expiração dele nunca detectava sessão inválida.
      await currentUser.getIdToken(true);
      return true;
    } catch (e) {
      debugPrint("Error checking Google bond: $e");
      return false;
    }
  }

  /// Indica se há uma sessão IdUFF que permite login silencioso, ou seja,
  /// um refresh token salvo e ainda não expirado. A verificação é local e não
  /// renova o token (o getAccessToken() antigo fazia refresh + userinfo na
  /// rede e, se o refresh falhasse, ainda retornava o access token antigo salvo).
  Future<bool> hasActiveIduffBond() async {
    try {
      final storedUser = await _userDataRepository.getUserIduffModel();
      if (storedUser == null || (storedUser.iduff?.isEmpty ?? true)) {
        return false;
      }
      if (!(storedUser.authData?.isLogged ?? false)) return false;

      final refreshToken = storedUser.authData?.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final expiration = _jwtExpiration(refreshToken);
      // Sem "exp" (ex.: offline token do Keycloak) => considera válido
      if (expiration == null) return true;

      final isExpired = DateTime.now().isAfter(
        expiration.subtract(const Duration(seconds: 30)),
      );
      if (isExpired) debugPrint("Iduff bond: refresh token is expired.");
      return !isExpired;
    } catch (e) {
      debugPrint("Error checking Iduff bond: $e");
      return false;
    }
  }

  /// Lê o claim "exp" de um JWT sem validar a assinatura.
  /// Retorna null se o token não tiver "exp" (ou exp == 0).
  DateTime? _jwtExpiration(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload is Map ? payload['exp'] : null;
    if (exp is! num || exp <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  Future<void> _loadBondStates() async {
    try {
      final results = await Future.wait([
        hasActiveIduffBond(),
        hasActiveGoogleBond(),
      ]);
      hasActiveIduffBondObs.value = results[0];
      hasActiveGoogleBondObs.value = results[1];
    } catch (e) {
      debugPrint("Error loading bond states: $e");
    }
  }

  Future<void> reloadBondStates() async {
    await _loadBondStates();
  }

  void _checkAdminPermission(final gdi) {
    final groups = _user.gdiGroups;
    if (groups == null || groups.isEmpty) {
      hasAdminPermission.value = false;
      return;
    }
    hasAdminPermission.value = groups.any((group) => group.gid == gdi);
  }

  void loginIDUFF() {
    Get.offAllNamed(
      Routes.AUTH,
      arguments: true,
    ); //Esse argumento é para iniciar a função de login automaticamente apenas quando o usuario aperta em login com iduff
  }

  Future<void> loginGoogle() async {
    isLoading.value = true;
    try {
      if(hasActiveGoogleBondObs.value){
        bool loginStatus = await _loginGoogleController.tryLogin();
        if(!loginStatus){
          await _loginGoogleController.loginGoogle();
        }
      }
      else{
        await _loginGoogleController.loginGoogle();

      }
    } catch (e) {
      await _loginGoogleController.loginGoogle();
    } finally {
      isLoading.value = false;
    }
  }

  void goToCarteirinhaPage() {
    Get.toNamed(Routes.CARTEIRINHA_DIGITAL);
  }

  void loginAnonimous() {
    Get.offAllNamed(Routes.HOME);
  }

  void goToCatracaOnlinePage() {
    Get.toNamed(Routes.CATRACA_ONLINE);
  }

  void logoutGoogle() {
    _loginGoogleController.logout();
  }
}
