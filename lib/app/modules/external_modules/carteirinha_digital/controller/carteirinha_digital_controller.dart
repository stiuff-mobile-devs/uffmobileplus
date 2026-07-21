import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/screen_protector_service.dart';

class CarteirinhaDigitalController extends GetxController {
  RxBool isBusy = false.obs;
  RxBool isQrCodeLoading = false.obs;

  Timer? expirationTimer;
  late var qrCodeData;

  late ExternalModulesServices _externalModulesServices;
  ScreenProtectorService screenProtector = ScreenProtectorService();

  String? getUserName() => _externalModulesServices.getUserName();
  String getUserMatricula() => _externalModulesServices.getUserMatricula();
  String getUserIdUFF() => _externalModulesServices.getUserIdUFF();
  String getUserCourse() => _externalModulesServices.getUserCourse();
  String? getUserPhotoUrl() => _externalModulesServices.getUserPhotoUrl();
  String getUserValidity() => _externalModulesServices.getUserValidity();
  String getUserBond() => _externalModulesServices.getUserBond();
  Future<String> getQrCodeData() => _externalModulesServices.getQrCodeData();

  @override
  void onInit() {
    super.onInit();
    screenProtector.enableScreenProtection();
    _initAsync();
  }

  Future<void> _initAsync() async {
    isBusy.value = true;
    _externalModulesServices = Get.find<ExternalModulesServices>();
    try {
      await _externalModulesServices.initialize();
    } catch (e) {
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
    qrCodeData = await _externalModulesServices.getQrCodeData();
    isBusy.value = false;
    update();
  }

  Future<void> updateQrCodeData() async {
    isQrCodeLoading.value = true;
    try {
      qrCodeData = await _externalModulesServices.updateQrCodeData();
    } catch (e) {
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
      isQrCodeLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    screenProtector.disableScreenProtection();
    super.onClose();
  }
}
