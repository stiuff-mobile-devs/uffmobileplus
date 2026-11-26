import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/screen_protector_service.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/utils/carteirinha_last_update.dart';

class CarteirinhaDigitalController extends GetxController {
  final RxBool isBusy = true.obs;

  /// Atualizando QR code e validade no SACI. O QR salvo continua na tela.
  final RxBool isRefreshing = false.obs;

  final RxString qrCodeData = ''.obs;
  final RxString validity = ''.obs;

  late ExternalModulesServices _externalModulesServices;
  ScreenProtectorService screenProtector = ScreenProtectorService();

  String? getUserName() => _externalModulesServices.getUserName();
  String getUserMatricula() => _externalModulesServices.getUserMatricula();
  String getUserIdUFF() => _externalModulesServices.getUserIdUFF();
  String getUserCourse() => _externalModulesServices.getUserCourse();
  String? getUserPhotoUrl() => _externalModulesServices.getUserPhotoUrl();
  String getUserValidity() => validity.value;
  String getUserBond() => _externalModulesServices.getUserBond();

  @override
  void onInit() {
    super.onInit();
    screenProtector.enableScreenProtection();
    _setMaxBrightness();
    _initAsync();
  }

  Future<void> _initAsync() async {
    isBusy.value = true;
    _externalModulesServices = Get.find<ExternalModulesServices>();
    try {
      await _externalModulesServices.initialize();
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'carregar dados da carteirinha');
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        titleText: Text(
          'erro'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          'erro_carregar_dados_carteirinha'.tr,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    // Mostra na hora o que está salvo e tenta atualizar em seguida; sem
    // resposta do SACI, fica valendo o último salvo, sem aviso.
    await _loadSaved();
    isBusy.value = false;
    unawaited(refreshCarteirinha(silent: true));
  }

  Future<void> _loadSaved() async {
    qrCodeData.value = await _externalModulesServices.getQrCodeData();
    validity.value = _externalModulesServices.getUserValidity();
  }

  /// Busca no SACI o QR code e a validade. Com [silent], uma falha não
  /// mostra aviso (abrir a carteirinha sem internet é uso normal).
  Future<void> refreshCarteirinha({bool silent = false}) async {
    if (isRefreshing.value) return;
    // Sem login idUFF não há o que buscar no SACI.
    if (getUserIdUFF().isEmpty) return;

    isRefreshing.value = true;
    try {
      await _externalModulesServices.refreshCarteirinhaData();
      await _loadSaved();
      await CarteirinhaLastUpdate.save(
        _externalModulesServices.getUserStorageKey(),
        DateTime.now(),
      );
    } catch (e) {
      // Sem relato aqui: a falha real do SACI já é relatada no getSaciData
      // (issue #39); o resto é falta de internet.
      debugPrint('Erro ao atualizar a carteirinha: $e');
      if (silent) return;
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        titleText: Text(
          'erro'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          'erro_atualizar_qr_code'.tr,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _setMaxBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e) {
      // Alguns dispositivos ou plataformas podem recusar a alteração
      debugPrint('Erro ao aumentar brilho da tela: $e');
    }
  }

  @override
  void onClose() {
    ScreenBrightness().resetApplicationScreenBrightness();
    screenProtector.disableScreenProtection();
    super.onClose();
  }
}
