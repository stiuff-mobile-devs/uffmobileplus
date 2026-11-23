import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/repository/catraca_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_version.dart';

/// Tela de informações da catraca (botão "?"): vinculações, conexões, ajuda
/// e versões. Só leitura: não altera nenhuma regra da catraca.
class CatracaInfoController extends GetxController {
  final CatracaOnlineRepository _repository = CatracaOnlineRepository();
  late final ExternalModulesServices _externalModulesServices;

  /// Domínio exigido para a conta Google do operador.
  static const String requiredGoogleDomain = '@id.uff.br';

  // Começa em true para a tela abrir em "verificando", não em "inativo".
  final RxBool isLoading = true.obs;
  bool _running = false;

  // Vinculações
  final RxBool hasIduffBond = false.obs;
  final RxBool hasGoogleBond = false.obs;
  final RxnString iduffEmail = RxnString();
  final RxnString googleEmail = RxnString();

  // Conexões (null = verificando)
  final RxnBool internet = RxnBool();
  final RxnBool sctm = RxnBool();
  final RxnBool saci = RxnBool();
  final RxnBool umm = RxnBool();
  final RxnInt pendingSync = RxnInt();

  final String catracaVersion = CatracaVersion.current;

  String get appVersion => Get.isRegistered<UmInfosService>()
      ? Get.find<UmInfosService>().version.value
      : '';

  Rxn<DateTime> get lastSyncAt => Get.isRegistered<CatracaController>()
      ? Get.find<CatracaController>().lastSyncAt
      : Rxn<DateTime>();

  bool get isGoogleEmailValid =>
      (googleEmail.value ?? '').toLowerCase().endsWith(requiredGoogleDomain);

  @override
  void onInit() {
    super.onInit();
    _externalModulesServices = Get.find<ExternalModulesServices>();
  }

  // O controller nasce durante o build da tela (GetView), então alterar os
  // observáveis já no onInit dispara "setState() called during build".
  // O onReady roda depois do primeiro frame.
  @override
  void onReady() {
    super.onReady();
    refreshAll();
  }

  Future<void> refreshAll() async {
    if (_running) return;
    _running = true;
    isLoading.value = true;
    internet.value = sctm.value = saci.value = umm.value = null;
    pendingSync.value = null;
    try {
      await Future.wait([_loadBonds(), _loadConnections(), _loadPendingSync()]);
    } catch (e) {
      debugPrint('Erro ao carregar informações da catraca: $e');
    } finally {
      isLoading.value = false;
      _running = false;
    }
  }

  Future<void> _loadBonds() async {
    final results = await Future.wait([
      _externalModulesServices.hasActiveIduffBond(),
      _externalModulesServices.hasActiveGoogleBond(),
    ]);
    hasIduffBond.value = results[0];
    hasGoogleBond.value = results[1];

    final google = _externalModulesServices.getUserEmailGoogle();
    googleEmail.value = (google == null || google.isEmpty) ? null : google;

    try {
      final email = await _externalModulesServices.getEmail();
      iduffEmail.value = email.isEmpty ? null : email;
    } catch (e) {
      // Sem internet ou sessão IdUFF: só fica sem o e-mail.
      debugPrint('Erro ao obter e-mail IdUFF na catraca: $e');
      iduffEmail.value = null;
    }
  }

  Future<void> _loadConnections() async {
    await Future.wait([
      InternetConnection().hasInternetAccess.then((v) => internet.value = v),
      _repository.getSctmStatus().then((v) => sctm.value = v),
      _repository.getSaciStatus().then((v) => saci.value = v),
      _repository.getUmmStatus().then((v) => umm.value = v),
    ]);
  }

  Future<void> _loadPendingSync() async {
    try {
      final all = await _repository.getOperatorTransactionsOffline();
      pendingSync.value = all.where((tx) => tx.isSynced == false).length;
    } catch (e, s) {
      CrashReporter.recordError(
        e,
        s,
        reason: 'contar refeições pendentes na tela de informações da catraca',
      );
      debugPrint('Erro ao contar transações pendentes: $e');
      pendingSync.value = null;
    }
  }
}
