import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';

class CarteirinhaDigitalController extends GetxController {
  RxBool isBusy = false.obs;
  RxBool isExpired = false.obs;
  RxBool isQrCodeLoading = false.obs;

  Timer? expirationTimer;
  late var qrCodeData;

  late ExternalModulesServices _externalModulesServices;

  @override
  void onInit() {
    super.onInit();
    _initAsync();
  }

  Future<void> _initAsync() async {
    isBusy.value = true;
    _externalModulesServices = Get.find<ExternalModulesServices>();
    try {
      await _externalModulesServices.initialize();
    } catch (e) {
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Atenção'),
            content: const Text(
              'Por gentileza efetue o login com seu idUFF, pelo menos uma vez, para que os dados de sua carteirinha sejam disponibilizados.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
    qrCodeData = await _externalModulesServices.getQrCodeData();
    isBusy.value = false;
    update();
  }

  String? getUserName() => _externalModulesServices.getUserName();
  String getUserMatricula() => _externalModulesServices.getUserMatricula();
  String getUserIdUFF() => _externalModulesServices.getUserIdUFF();
  String getUserCourse() => _externalModulesServices.getUserCourse();
  String getUserPhotoUrl() => _externalModulesServices.getUserPhotoUrl();
  String getUserValidity() => _externalModulesServices.getUserValidity();
  String getUserBond() => _externalModulesServices.getUserBond();
  Future<String> getQrCodeData() => _externalModulesServices.getQrCodeData();

  void handleTimeout() {
    isExpired.value = true;
    update();
  }

  // ...existing code...
  updateQrCodeData() async {
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
        titleText: const Text(
          'Erro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: const Text(
          'Erro ao atualizar o QR Code',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } finally {
      isQrCodeLoading.value = false;
      update();
    }
  }
}
