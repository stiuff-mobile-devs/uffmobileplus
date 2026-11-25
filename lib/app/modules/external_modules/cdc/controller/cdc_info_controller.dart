import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_google_chat_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/utils/cdc_version.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

/// Tela de informações da Central (botão "?"): conta Google, permissão das
/// salas do Chat, manual e versões.
class CdcInfoController extends GetxController {
  final ExternalModulesServices _externalModulesServices =
      Get.find<ExternalModulesServices>();

  /// Só contas institucionais mostram salas do Google Chat.
  static const String uffEmailDomain = '@id.uff.br';

  // Começa em true para a tela abrir em "verificando", não em "inativa".
  final RxBool isLoading = true.obs;
  bool _running = false;

  final RxBool hasGoogleBond = false.obs;
  final RxnString googleEmail = RxnString();

  /// Permissão de ver as salas do Google Chat (null = verificando).
  final RxnBool chatPermission = RxnBool();

  final String cdcVersion = CdcVersion.current;

  String get appVersion => Get.isRegistered<UmInfosService>()
      ? Get.find<UmInfosService>().version.value
      : '';

  bool get isUffEmail =>
      (googleEmail.value ?? '').toLowerCase().endsWith(uffEmailDomain);

  // O controller nasce durante o build da tela; a carga fica no onReady.
  @override
  void onReady() {
    super.onReady();
    refreshAll();
  }

  Future<void> refreshAll() async {
    if (_running) return;
    _running = true;
    isLoading.value = true;
    chatPermission.value = null;
    try {
      hasGoogleBond.value = await _externalModulesServices.hasActiveGoogleBond();
      final email = _externalModulesServices.getUserEmailGoogle();
      googleEmail.value = (email == null || email.isEmpty) ? null : email;
      chatPermission.value = hasGoogleBond.value && isUffEmail
          ? await _hasChatPermission(interactive: false)
          : false;
    } catch (e, s) {
      CrashReporter.recordError(
        e,
        s,
        reason: 'carregar tela de informações do cdc',
      );
      debugPrint('CDC info: erro ao carregar - $e');
    } finally {
      isLoading.value = false;
      _running = false;
    }
  }

  Future<bool> _hasChatPermission({required bool interactive}) async {
    final headers = await _externalModulesServices.getGoogleAuthHeaders(
      [CdcGoogleChatProvider.scope],
      interactive: interactive,
    );
    return headers != null;
  }

  /// Toque na conta Google: conecta ou desconecta sem sair da tela.
  Future<void> onGoogleTap() async {
    final changed = await _externalModulesServices.toggleGoogleBond(
      logoutNote: 'cdc_nota_sem_google'.tr,
    );
    if (!changed) return;
    await refreshAll();
    _reloadCentral();
  }

  /// "Permitir acesso": pede a permissão de ver as salas do Chat.
  Future<void> onPermissionTap() async {
    if (!hasGoogleBond.value || !isUffEmail) return;
    try {
      final ok = await _hasChatPermission(interactive: true);
      chatPermission.value = ok;
      if (ok) _reloadCentral(force: true);
    } catch (e, s) {
      CrashReporter.recordError(
        e,
        s,
        reason: 'pedir permissão do google chat no cdc',
      );
      AppPopups.error(
        'tente_novamente_mais_tarde'.tr,
        title: 'cdc_google_chat_erro_titulo'.tr,
      );
    }
  }

  /// Atualiza as salas da Central (tela anterior) com a conta atual.
  void _reloadCentral({bool force = false}) {
    if (Get.isRegistered<CdcController>()) {
      Get.find<CdcController>().loadRooms(force: force);
    }
  }
}
