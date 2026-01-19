import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class MonitoraUffController extends GetxController {
  final RxBool isGathering = false.obs; // Determina se usuário está sendo monitorado
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null); // Coordenadas do usuário
  final MapController mapController = MapController(); // Controlador do mapa
  final RxList<Marker> remoteMarkers = <Marker>[].obs; // Marcadores de usuários remotos
  String? myDeviceId; // ID do dispositivo do usuário
  StreamSubscription? _serviceSubscription; // Ouvir atualizações do serviço

  @override
  void onInit() {
    super.onInit();
    _fetchDeviceId();
    _connectToService();
    _listenToRemoteLocations();
  }

  @override
  void onClose() {
    _serviceSubscription?.cancel();
    super.onClose();
  }

  void _connectToService() {
    final service = FlutterBackgroundService();
    
    _serviceSubscription = service.on('updateLocation').listen((event) {
        // Note: curto circuito para evitar null
        if (event != null && event['lat'] != null && event['lng'] != null) {
            double lat = event['lat'];
            double lng = event['lng'];
            
            currentPosition.value = LatLng(lat, lng);
        }
    });

    service.on('trackingStatus').listen((event) {
        if (event != null && event['isTracking'] != null) {
            isGathering.value = event['isTracking'];
            if (isGathering.value == false) {
                currentPosition.value = null;
            }
        }
    });

    service.isRunning().then((running) {
        isGathering.value = running;
        if (running) {
             service.invoke('requestUpdate');
        }
    });
  }

  Future<void> _fetchDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          myDeviceId = androidInfo.id;
      } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          myDeviceId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      print('Controller: Error getting device ID: $e');
    }
  }

  void _listenToRemoteLocations() {
      // Use a instância padrão do app ou garanta que estamos usando a correta se nomeada.
      // Como o LocationService usa o app 'tracking', devemos verificar se o app principal usa o padrão ou tracking.
      // Geralmente o app principal usa o padrão. Vamos assumir que podemos acessar o app 'tracking' se inicializado ou padrão.
      // Idealmente, o app principal deve inicializar o Firebase. Se estiver inicializado, podemos acessá-lo.
      // Se o app 'tracking' estiver apenas no isolate de segundo plano, podemos precisar buscar segurança.
      // Mas tipicamente usamos a instância padrão na UI. Vamos tentar o padrão primeiro.
      
      FirebaseFirestore.instance.collection('live_locations').snapshots().listen((snapshot) {
          remoteMarkers.clear();
          for (var doc in snapshot.docs) {
              final data = doc.data();
              final String? deviceId = data['deviceId'];
              final bool? isMonitored = data['isMonitored'];
              
              // Pular se for eu mesmo
              if (deviceId == myDeviceId) continue;

              if (isMonitored != true) continue;

              final double? lat = data['latitude'];
              final double? lng = data['longitude'];

              if (lat != null && lng != null) {
                  remoteMarkers.add(
                      Marker(
                          point: LatLng(lat, lng),
                          width: 80,
                          height: 80,
                          child: Icon(Icons.location_pin, color: Colors.blueAccent, size: 40),
                      ),
                  );
              }
          }
      });
  }

  void toggleGathering(bool value) async {
    final service = FlutterBackgroundService();
    if (value) {
      bool hasPermission = await _handlePermission();
      if (!hasPermission) {
          isGathering.value = false;
          return;
      }
      // Garantir que o serviço está rodando antes de invocar
      if (!(await service.isRunning())) {
        await service.startService();
        // Aguardar o isolate de segundo plano inicializar e registrar ouvintes
        await Future.delayed(const Duration(seconds: 2));
      }
      service.invoke('startTracking');
    } else {
      currentPosition.value = null; // Immediate UI update
      service.invoke('stopTracking');
      // Opcionalmente parar o serviço completamente se quisermos limpar a notificação
      service.invoke('stopService'); 
    }
    isGathering.value = value;
  }

  // Esta função é responsável por verificar se o serviço de localização está habilitado e solicitar permissão ao usuário se necessário.
  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verifica se tem permissão
    // se não tiver, solicita permissão
    // e se o usuário negar, retorna false.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    } 

    return true;
  }
}
