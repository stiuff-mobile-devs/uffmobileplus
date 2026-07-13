import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_iduff_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';

class LoginController extends GetxController {
  bool showQrCode = false;
  late String versionCode;
  late final AuthGoogleController _loginGoogleController;
  late UmInfosService _umInfosService;
  late AuthIduffService _authIduffService;

  UserGoogleRepository userGoogleRepository = UserGoogleRepository();
  UserDataRepository userDataRepository = UserDataRepository();
  UserIduffRepository userIduffRepository = UserIduffRepository();

  UserData _user = UserData();

  RxBool hasAdminPermission = false.obs;
  RxBool hasActiveIduffBondObs = false.obs;
  RxBool hasActiveGoogleBondObs = false.obs;

  RxBool isLoading = false.obs;

  @override
  Future<void> onInit() async {
    _loginGoogleController = Get.find<AuthGoogleController>();
    _umInfosService = Get.find<UmInfosService>();
    _authIduffService = Get.find<AuthIduffService>();

    versionCode = _umInfosService.version.value;
    _user = (await userDataRepository.getUserData()) ?? UserData();

    _checkAdminPermission(GdiGroupsEnum.controladoresDeAcesso.id);
    _loadBondStates();
    super.onInit();
  }

  Future<bool> hasActiveGoogleBond() async {
    try {
      final currentUser = fb.FirebaseAuth.instanceFor(
        app: Firebase.app('uffmobileplus'),
      ).currentUser;
      final storedUser = await userGoogleRepository.getUserGoogleModel();
      final hasStoredUser = storedUser != null && storedUser.email.isNotEmpty;
      return currentUser != null && hasStoredUser;
    } catch (e) {
      debugPrint("Error checking Google bond: $e");
      return false;
    }
  }

  Future<bool> hasActiveIduffBond() async {
    try {
      final storedUser = await userIduffRepository.getUserIduffModel();
      final hasStoredUser =
          storedUser != null && (storedUser.iduff?.isNotEmpty ?? false);
      final isLogged = storedUser?.authData?.isLogged ?? false;
      final accessToken = await _authIduffService.getAccessToken();
      final hasToken = accessToken != null && accessToken.isNotEmpty;
      return hasStoredUser && isLogged && hasToken;
    } catch (e) {
      debugPrint("Error checking Iduff bond: $e");
      return false;
    }
  }

  Future<void> _loadBondStates() async {
    try {
      hasActiveIduffBondObs.value = await hasActiveIduffBond();
      hasActiveGoogleBondObs.value = await hasActiveGoogleBond();
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
      await _loginGoogleController.loginGoogle();
    } catch (e) {
      debugPrint("Erro no login google");
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
