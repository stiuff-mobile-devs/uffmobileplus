import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/utils/bond_status.dart'
    as bond_status;
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';

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

  /// Indica se há uma sessão Google que permite login silencioso. A lógica
  /// fica em `user/utils/bond_status.dart`, compartilhada com os módulos
  /// externos via `ExternalModulesServices`.
  Future<bool> hasActiveGoogleBond() => bond_status.hasActiveGoogleBond();

  /// Indica se há uma sessão IdUFF que permite login silencioso (refresh
  /// token salvo e ainda não expirado). Ver `user/utils/bond_status.dart`.
  Future<bool> hasActiveIduffBond() => bond_status.hasActiveIduffBond();

  Future<void> _loadBondStates() async {
    try {
      final results = await Future.wait([
        hasActiveIduffBond(),
        hasActiveGoogleBond(),
      ]);
      hasActiveIduffBondObs.value = results[0];
      hasActiveGoogleBondObs.value = results[1];
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'carregar estado dos vínculos');
      debugPrint("Error loading bond states: $e");
    }
  }

  Future<void> reloadBondStates() async {
    await _loadBondStates();
  }

  /// Relê o usuário salvo (ex.: após um novo login) para atualizar a
  /// permissão de administrador e o estado das vinculações.
  Future<void> reloadUserData() async {
    _user = (await _userDataRepository.getUserData()) ?? UserData();
    _checkAdminPermission(GdiGroupsEnum.controladoresDeAcesso.id);
    await _loadBondStates();
  }

  /// Atalho da catraca no login: aparece mesmo sem sessão, para o operador
  /// usar a catraca offline com os dados do Hive. Vale o grupo vindo do
  /// IdUFF ou do Google (regra única em `isCatracaOperator`).
  void _checkAdminPermission(final gdi) {
    hasAdminPermission.value = isCatracaOperator(
      iduffGids: (_user.gdiGroups ?? []).map((g) => g.gid),
      googleGids: (_user.gdiGroupsGoogle?.gdiGroups ?? []).map((g) => g.gid),
      googleEmails: (_user.gdiGroupsGoogle?.gdiGroups ?? []).map(
        (g) => g.email,
      ),
    );
  }

  void loginIDUFF() {
    Get.offAllNamed(
      Routes.AUTH,
      arguments: true,
    ); //Esse argumento é para iniciar a função de login automaticamente apenas quando o usuario aperta em login com iduff
  }

  /// Faz o login Google e retorna o usuário logado, ou `null` se não concluiu.
  ///
  /// [navigate] falso: não troca de tela (login pelas Configurações).
  /// [skipGoogleOnlyConfirm]: quem chamou já fez [confirmGoogleOnlyLoginIfNeeded].
  Future<UserGoogleModel?> loginGoogle({
    bool navigate = true,
    bool skipGoogleOnlyConfirm = false,
  }) async {
    if (!skipGoogleOnlyConfirm && !await confirmGoogleOnlyLoginIfNeeded()) {
      return null;
    }

    isLoading.value = true;
    try {
      if (hasActiveGoogleBondObs.value) {
        try {
          if (await _loginGoogleController.tryLogin(navigate: navigate)) {
            return await _userDataRepository.getUserGoogleModel();
          }
        } catch (e) {
          // Login silencioso falhou: cai no login interativo abaixo.
          debugPrint('Erro no login Google silencioso: $e');
        }
      }
      return await _loginGoogleController.loginGoogle(navigate: navigate);
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'login google pela tela de login');
      // O erro já foi mostrado ao usuário; tentar de novo aqui abria o
      // seletor de contas uma segunda vez.
      debugPrint('Erro no login Google: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Aviso só faz sentido quando o Google será o único vínculo.
  Future<bool> confirmGoogleOnlyLoginIfNeeded() async {
    if (hasActiveIduffBondObs.value) return true;
    return _confirmGoogleOnlyLogin();
  }

  Future<bool> _confirmGoogleOnlyLogin() {
    return AppPopups.confirm(
      title: 'atencao'.tr,
      message: 'aviso_login_google_msg'.tr,
      icon: Icons.warning_amber_rounded,
      type: PopupType.warning,
      confirmText: 'continuar'.tr,
      dismissible: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in [
            'carteirinha_digital'.tr,
            'aviso_login_google_pagamentos_ru'.tr,
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.block_rounded, size: 18, color: Colors.white70),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
