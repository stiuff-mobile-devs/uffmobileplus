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

import 'package:uffmobileplus/app/data/services/external_modules_services.dart';

class MonitoraUffController extends GetxController {
  final RxBool isGathering =
      false.obs; // Determina se usuário está sendo monitorado
  ExternalModulesServices externalModulesServices =
      Get.find<ExternalModulesServices>();
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(
    null,
  ); // Coordenadas do usuário
  final MapController mapController = MapController(); // Controlador do mapa
  final RxList<Marker> remoteMarkers =
      <Marker>[].obs; // Marcadores de usuários remotos
  String? myDeviceId; // ID do dispositivo do usuário
  StreamSubscription? _serviceSubscription; // Ouvir atualizações do serviço

  @override
  void onInit() {
    super.onInit();
    externalModulesServices.initialize(); // Ensure services are initialized
    _fetchDeviceId();
    _connectToService();

    // Aguarda um pouco para garantir que Firebase foi inicializado
    Future.delayed(Duration(milliseconds: 500), () {
      _listenToRemoteLocations();
    });
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
    try {
      FirebaseFirestore.instance
          .collection('live_locations')
          .snapshots()
          .listen(
            (snapshot) {
              remoteMarkers.clear();
              for (var doc in snapshot.docs) {
                final data = doc.data();
                final String? matricula = data['matricula'];
                final String? name = data['name'];
                final bool? isMonitored = data['isMonitored'];

                final myMatricula = externalModulesServices.getUserMatricula();
                if (matricula == myMatricula) continue;

                if (isMonitored != true) continue;

                final double? lat = data['latitude'];
                final double? lng = data['longitude'];

                if (lat != null && lng != null) {
                  remoteMarkers.add(
                    Marker(
                      point: LatLng(lat, lng),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          if (matricula != null) {
                            showMarkerInfo(name);
                          }
                        },
                        child: Column(
                          children: [
                            if (name != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.blueAccent),
                                ),
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Icon(
                              Icons.location_pin,
                              color: Colors.blueAccent,
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            onError: (e) {
              print('Erro ao ouvir live_locations: $e');
            },
          );
    } catch (e) {
      print('Erro ao iniciar _listenToRemoteLocations: $e');
    }
  }

  void showMarkerInfo(String? name) {
    Get.defaultDialog(
      title: "Informações do Usuário",
      content: Column(
        children: [
          Text("Nome:"),
          Text(
            name ?? "Desconhecido",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  void toggleGathering(bool value) async {
    final service = FlutterBackgroundService();
    if (value) {
      bool hasPermission = await _handlePermission();
      if (!hasPermission) {
        isGathering.value = false;
        return;
      }
      // Validation: Check matricula
      String matricula = externalModulesServices.getUserMatricula();
      String? name = externalModulesServices.getUserName();

      if (matricula == "-" || matricula.isEmpty) {
        Get.snackbar(
          "Erro",
          "Matricula inválida. Não é possível iniciar o monitoramento.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        isGathering.value = false;
        return;
      }

      // Garantir que o serviço está rodando antes de invocar
      if (!(await service.isRunning())) {
        await service.startService();
        // Aguardar o isolate de segundo plano inicializar e registrar ouvintes
        await Future.delayed(const Duration(seconds: 2));
      }
      service.invoke('startTracking', {
        'matricula': matricula,
        'name': name ?? 'Unknown',
      });
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
