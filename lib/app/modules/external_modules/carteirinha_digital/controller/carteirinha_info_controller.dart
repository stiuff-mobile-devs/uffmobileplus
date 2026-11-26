import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/utils/carteirinha_last_update.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/utils/carteirinha_version.dart';

/// Tela de informações da carteirinha (botão "?"): conta IdUFF, última
/// atualização do QR code, manual e versões.
class CarteirinhaInfoController extends GetxController {
  final ExternalModulesServices _externalModulesServices =
      Get.find<ExternalModulesServices>();

  // Começa em true para a tela abrir em "verificando", não em "inativa".
  final RxBool isLoading = true.obs;
  bool _running = false;

  final RxBool hasIduffBond = false.obs;
  final RxnString iduff = RxnString();
  final RxnString userName = RxnString();

  /// Última atualização do QR code no SACI (null = nunca atualizado na tela).
  final Rxn<DateTime> lastUpdate = Rxn<DateTime>();

  final String carteirinhaVersion = CarteirinhaVersion.current;

  String get appVersion => Get.isRegistered<UmInfosService>()
      ? Get.find<UmInfosService>().version.value
      : '';

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
    try {
      hasIduffBond.value = await _externalModulesServices.hasActiveIduffBond();
      final id = _externalModulesServices.getUserIdUFF();
      iduff.value = id.isEmpty ? null : id;
      final name = _externalModulesServices.getUserName();
      userName.value = (name == null || name.isEmpty) ? null : name;
      lastUpdate.value = await CarteirinhaLastUpdate.read(
        _externalModulesServices.getUserStorageKey(),
      );
    } catch (e, s) {
      CrashReporter.recordError(
        e,
        s,
        reason: 'carregar tela de informações da carteirinha',
      );
      debugPrint('Carteirinha info: erro ao carregar - $e');
    } finally {
      isLoading.value = false;
      _running = false;
    }
  }

  /// Toque na conta IdUFF: conecta ou desconecta (os dois saem da tela).
  Future<void> onIduffTap() async {
    await _externalModulesServices.toggleIduffBond(
      loginNote: 'carteirinha_nota_sair_para_iduff'.tr,
      logoutNote: 'carteirinha_nota_sem_iduff'.tr,
    );
  }

  /// "26/11/2026 às 14:32", ou null se nunca foi atualizado.
  String? get lastUpdateText {
    final d = lastUpdate.value;
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return 'carteirinha_info_qr_atualizado_em'.trParams({
      'data': '${two(d.day)}/${two(d.month)}/${d.year}',
      'hora': '${two(d.hour)}:${two(d.minute)}',
    });
  }
}
