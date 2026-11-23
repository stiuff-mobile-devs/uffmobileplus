import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_umm_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

/// Conectar/desconectar as vinculações IdUFF e Google, com as confirmações
/// das Configurações. Usado pelas Configurações e, via
/// `ExternalModulesServices`, pelos módulos externos (ex.: catraca).
///
/// [note] acrescenta um aviso à mensagem de confirmação (texto já traduzido).
class BondActions {
  BondActions._();

  static LoginController get _login {
    if (!Get.isRegistered<AuthGoogleController>()) {
      Get.put(AuthGoogleController());
    }
    if (!Get.isRegistered<LoginController>()) Get.put(LoginController());
    return Get.find<LoginController>();
  }

  static AuthGoogleController get _authGoogle {
    if (!Get.isRegistered<AuthGoogleController>()) {
      Get.put(AuthGoogleController());
    }
    return Get.find<AuthGoogleController>();
  }

  static String _withNote(String message, String? note) =>
      (note == null || note.isEmpty) ? message : '$message\n\n$note';

  /// Confirma e abre a autenticação IdUFF (sai da tela atual).
  static Future<void> confirmIduffLogin({String? note}) async {
    final ok = await AppPopups.confirm(
      title: 'login_iduff_titulo'.tr,
      message: _withNote('login_iduff_confirmacao_msg'.tr, note),
      icon: Icons.login_rounded,
      confirmText: 'continuar'.tr,
    );
    if (ok) _login.loginIDUFF();
  }

  /// Confirma e desconecta o IdUFF, voltando para o login.
  static Future<void> confirmIduffLogout({String? note}) async {
    final ok = await AppPopups.confirm(
      title: 'desconectar_iduff_titulo'.tr,
      message: _withNote('desconectar_iduff_confirmacao_msg'.tr, note),
      icon: Icons.link_off_rounded,
      confirmText: 'desconectar'.tr,
      destructive: true,
    );
    if (ok) await logoutIduff();
  }

  static Future<void> logoutIduff() async {
    // Apaga também matrícula/nome/curso/perfil: assim o próximo login IdUFF
    // consulta a UMM de novo em vez de reaproveitar os dados da conta anterior.
    await UserDataRepository().clearIduffProfileData();
    await UserUmmRepository().deleteUserUmmModel();
    CrashReporter.clearUser();
    Get.offAllNamed(Routes.LOGIN);
  }

  /// Confirma e faz o login Google sem trocar de tela. Devolve o usuário, ou
  /// `null` se não concluiu.
  static Future<UserGoogleModel?> confirmGoogleLogin() async {
    final login = _login;
    final ok = await AppPopups.confirm(
      title: 'login_google_titulo'.tr,
      message: 'login_google_confirmacao_msg'.tr,
      icon: Icons.login_rounded,
      confirmText: 'continuar'.tr,
    );
    if (!ok || !await login.confirmGoogleOnlyLoginIfNeeded()) return null;

    AppPopups.showLoading('conectando_google'.tr);
    try {
      return await login.loginGoogle(
        navigate: false,
        skipGoogleOnlyConfirm: true,
      );
    } finally {
      AppPopups.hideLoading();
    }
  }

  /// Confirma e desconecta o Google. Com [stayOnScreen], só limpa a sessão
  /// (fica na tela atual); senão volta para o login, como nas Configurações.
  /// Devolve `true` se desconectou.
  static Future<bool> confirmGoogleLogout({
    String? note,
    bool stayOnScreen = false,
  }) async {
    final ok = await AppPopups.confirm(
      title: 'desconectar_google_titulo'.tr,
      message: _withNote('desconectar_google_confirmacao_msg'.tr, note),
      icon: Icons.link_off_rounded,
      confirmText: 'desconectar'.tr,
      destructive: true,
    );
    if (!ok) return false;
    if (stayOnScreen) {
      await _authGoogle.disconnect();
    } else {
      await _authGoogle.logout();
    }
    return true;
  }
}
