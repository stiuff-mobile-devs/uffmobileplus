import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/data/repository/sos_repository.dart';

class SosController extends GetxController {
  final ExternalModulesServices _externalModulesServices =
      Get.find<ExternalModulesServices>();

  final SosRepository _repository = Get.find<SosRepository>();

  final RxBool isLoading = false.obs;
  bool _isPermissionGranted = false;
  bool _isUserLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _inicializarTudo();
  }

  Future<void> _inicializarTudo() async {
    try {
      await _externalModulesServices.initialize();
      _isUserLoaded = true;
    } catch (e) {
      _mostrarDialogoBloqueio("erro".tr, "nao_foi_possivel_carregar_dados".tr);
      return;
    }
    await _verificarPermissoesGPS();
  }

  Future<void> _verificarPermissoesGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarDialogoBloqueio("gps_desligado".tr, "gps_desligado_msg".tr);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _mostrarDialogoBloqueio(
            "permissao_negada".tr,
            "permissao_negada_msg".tr,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _mostrarDialogoBloqueio(
          "permissao_bloqueada".tr,
          "permissao_bloqueada_msg".tr,
          abrirConfiguracoes: true,
        );
        return;
      }

      _isPermissionGranted = true;
    } catch (e) {
      _mostrarDialogoBloqueio("erro".tr, "falha_ao_verificar_gps".tr);
    }
  }

  void _mostrarDialogoBloqueio(
    String titulo,
    String mensagem, {
    bool abrirConfiguracoes = false,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          if (abrirConfiguracoes)
            TextButton(
              onPressed: () {
                Get.back();
                Geolocator.openAppSettings();
                Get.back();
              },
              child: Text("configuracoes".tr),
            ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text("voltar".tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> sendSos() async {
    if (!_isUserLoaded) return;
    if (!_isPermissionGranted) {
      await _verificarPermissoesGPS();
      if (!_isPermissionGranted) return;
    }

    isLoading.value = true;

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));

      final String matricula = _externalModulesServices.getUserMatricula();
      final String? nome = _externalModulesServices.getUserName();
      print(
        "User: $nome | Matricula: $matricula | Lat: ${position.latitude} | Lng: ${position.longitude}",
      );

      final bool success = await _repository.sendSos(
        nome: nome,
        matricula: matricula,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (success) {
        Get.snackbar(
          'sos'.tr,
          'sos_sucesso_envio'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      } else {
        throw Exception("API retornou erro");
      }
    } catch (e) {
      Get.snackbar(
        "erro".tr,
        "sos_falha_envio".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
