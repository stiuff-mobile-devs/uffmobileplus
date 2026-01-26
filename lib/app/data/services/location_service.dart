import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:uffmobileplus/app/data/services/device_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';

class LocationService extends GetxService {
  LocationPermission? permission;
  bool serviceEnabled = false;
  final Rx<Position?> position = Rx<Position?>(null);
  Timer? _locationTimer;
  bool _isTracking = false;
  String? deviceId;

  Future<LocationService> init() async {
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
      await _fetchCurrentLocation();
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      position.value = await Geolocator.getCurrentPosition(
        timeLimit: Duration(seconds: 10),
      );

      startTracking();

      UserLocationModel userLocationModel = _createUserLocationModel();
      await FirebaseProvider().adicionarDados(userLocationModel);
    } catch (e) {
      print('Erro ao buscar localização: $e');
    }
  }

  /// Inicia rastreamento contínuo do veículo
  void startTracking({Duration interval = const Duration(seconds: 10)}) {
    if (_isTracking) {
      return;
    }

    _isTracking = true;

    _locationTimer = Timer.periodic(interval, (_) async {
      await _fetchCurrentLocation();
      print(
        'Localização atualizada: ${position.value?.latitude}, ${position.value?.longitude}',
      );
    });
  }

  /// Para o rastreamento
  void stopTracking() {
    if (_isTracking) {
      _locationTimer?.cancel();
      _isTracking = false;
      print('Rastreamento parado');
      Get.snackbar('Info', 'Rastreamento parado');
    }
  }

  /// Verifica se está rastreando
  bool get isTracking => _isTracking;

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

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  UserLocationModel _createUserLocationModel() {
    return UserLocationModel(
      id: deviceId ?? 'unknown_device',
      lat: position.value?.latitude ?? 0.0,
      lng: position.value?.longitude ?? 0.0,
      timestamp: DateTime.now(),
    );
  }
}
