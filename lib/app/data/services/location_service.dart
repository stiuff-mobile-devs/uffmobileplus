import 'package:flutter/foundation.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:uffmobileplus/app/data/services/device_service.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';

class LocationService extends GetxService {
  LocationPermission? permission;
  bool serviceEnabled = false;
  final Rx<Position?> position = Rx<Position?>(null);
  final RxBool isTracking = false.obs;
  Timer? locationTimer;
  String? deviceId;
  late ExternalModulesServices _externalModulesServices;

  Future<LocationService> init() async {
    _externalModulesServices = Get.find<ExternalModulesServices>();
    _externalModulesServices.initialize();
    await Future.delayed(Duration(milliseconds: 500));
    await _initializeLocation();
    return this;
  }

  Future<void> _initializeLocation() async {
    try {
      // 1. Mostrar pop-up explicativo
      await _showLocationExplanationDialog();

      // 2. Verificar se o serviço de localização está ativado
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationDisabledDialog();
        await Geolocator.openLocationSettings();

        // Aguardar e tentar novamente após retornar das configurações
        await Future.delayed(Duration(seconds: 2));
        serviceEnabled = await Geolocator.isLocationServiceEnabled();

        if (!serviceEnabled) {
          Get.snackbar('Erro', 'Localização permanece desativada');
          return;
        }
      }

      // 3. Verificar permissões
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      deviceId = (await DeviceService.getBuildNumber()).toString();
      // Pega localização inicial
      //await _fetchCurrentLocation(); // TODO: atenção aqui
      position.value = await Geolocator.getCurrentPosition();

      /* TODO: o método abaixo, que ativa a localização, está sendo chamado
      aqui na inicialização, isto significa que ao entrar no módulo, o usuário
      terá sua localização compartilhada. Esse mecanismo deve ser aprimorado */
      startTracking();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter localização: $e');
      }
    }
  }

  /// Inicia rastreamento contínuo
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 10),
  }) async {
    if (locationTimer == null || !locationTimer!.isActive) {
      if (kDebugMode) {
        print('Timer periódico inicializado');
      }

      locationTimer = Timer.periodic(interval, (_) async {
        final currentPosition = await Geolocator.getCurrentPosition();
        position.value = currentPosition;

        if (await FirebaseProvider().doesDocumentExist(deviceId!)) {
          updateUser();
        } else {
          createNewUser();
        }

        if (kDebugMode) {
          print(
            'Localização atualizada localmente com sucesso: ${position.value?.latitude}, ${position.value?.longitude}',
          );
        }
      });
      await FirebaseProvider().updateIsTracked(
        deviceId ?? 'unknown_device',
        true,
      );
      isTracking.value = true;
    }
  }

  /// Para o rastreamento
  Future<void> stopTracking() async {
    if (locationTimer == null || !locationTimer!.isActive) return;

    locationTimer?.cancel();
    await FirebaseProvider().updateIsTracked(
      deviceId ?? 'unknown_device', // TODO: melhorar
      false,
    );
    isTracking.value = false;
    if (kDebugMode) {
      print('Rastreamento parado');
    }
  }

  Future<void> _showLocationExplanationDialog() async {
    return Get.dialog(
      AlertDialog(
        title: Text('Localização Necessária'),
        content: Text(
          'Precisamos acessar sua localização para rastrear o veículo e fornecer dados em tempo real.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Entendi')),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showLocationDisabledDialog() async {
    return Get.dialog(
      AlertDialog(
        title: Text('Localização Desativada'),
        content: Text(
          'A localização está desativada. Você será redirecionado para ativar nas configurações do dispositivo.',
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('OK'))],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> createNewUser() async {
    await FirebaseProvider().adicionarDados(
      UserLocationModel(
        id: deviceId ?? 'unknown_device',
        lat: position.value?.latitude ?? 0.0,
        lng: position.value?.longitude ?? 0.0,
        timestamp: DateTime.now(),
        nome: _externalModulesServices.getUserName(),
        iduff: _externalModulesServices.getUserIdUFF(),
        isTracked: isTracking.value,
      ),
    );
  }

  Future<void> updateUser() async {
    await FirebaseProvider().updateLocationAndTimestamp(
      deviceId ?? 'unknown_device',
      position.value?.latitude ?? 0.0,
      position.value?.longitude ?? 0.0,
      DateTime.now(),
    );
  }

  @override
  Future<void> onClose() async {
    stopTracking(); 
    super.onClose();
  }
}
