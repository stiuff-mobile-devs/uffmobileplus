import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/device_service.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';
import 'package:uffmobileplus/app/data/services/foreground_service.dart';

class MonitoraUffController extends GetxController {
  final FlutterBackgroundService _service = FlutterBackgroundService();
  late String deviceId;
  Position position = Position(
    latitude: -22.9041, // latitude em Niterói
    longitude: -43.1329, // longitude em Niterói
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  RxList<UserLocationModel> firebaseUsers = <UserLocationModel>[].obs;
  late final MapController mapController;
  final isTrackingEnabled = false.obs;
  late ExternalModulesServices _externalModulesServices;

  void centerMapOnCurrentLocation() {
    try {
      mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      if (kDebugMode) print('Error moving map: $e');
    }
  }

  @override
  Future<void> onInit() async {
    // Getx irá automaticamente atualizar 'firebaseUsers' sempre que os
    // documentos forem atualizados na nuvem
    firebaseUsers.bindStream(FirebaseProvider().getAllUsers());

    super.onInit();
    mapController = MapController();
    deviceId = (await DeviceService.getBuildNumber()).toString();
    _externalModulesServices = Get.find<ExternalModulesServices>();
    await _externalModulesServices.initialize();
    _handleLocationService();
    _handlePermission();
    isTrackingEnabled.value = await _service.isRunning();
  }

  /// Método utilizado para escolher a cor dos pins, determinando uma cor
  /// especial para o pin correspondente à localização do próprio usuário
  /// e outra para os demais.
  Color setMarkerColor(UserLocationModel someUser) {
    String currentUserId = _externalModulesServices.getUserIdUFF();
    return someUser.iduff == currentUserId
        ? Colors.indigo
        : Colors.lightBlue;
  }


  Future<void> toggleService() async {
    var isRunning = await _service.isRunning();

    if (isRunning) {
      _stopService();
    } else {
      _startService();
    }
  }

  Future<void> _setPlatformSpecifics() async {
    await _service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        // Esta linha conecta os isolates.
        onStart: onStart,
        // true -> Foreground
        // false -> Background
        isForegroundMode: true,
        autoStart: false,
        autoStartOnBoot: false,
      ),
    );
  }

  Future<void> _startService() async {
    await _setPlatformSpecifics();
    await _service.startService();

    // Este listener ouve o serviço em foreground avisar que está pronto para
    // receber informações do usuário.
    _service.on('ready').listen((event) {
      _service.invoke("setUserInfo", {
        "id": _externalModulesServices.getUserIdUFF(),
        "name": _externalModulesServices.getUserName(),
      });
    });

    // Este listener ouve atualizações da posição por parte do serviço em
    // foreground.
    _service.on('updateLocationLocally').listen((event) {
      if (event != null) {
        position = Position.fromMap(event['position']);
      }
    });

    isTrackingEnabled.value = true;
    FirebaseProvider().updateIsTracked(deviceId, true);
  }

  Future<void> _stopService() async {
    _service.invoke("stopService");
    isTrackingEnabled.value = false;
    FirebaseProvider().updateIsTracked(deviceId, false);
  }

  Future<void> _handleLocationService() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
  }

  Future<void> _handlePermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }
}
