import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        WidgetsBinding,
        WidgetsBindingObserver,
        AlertDialog,
        Text,
        TextButton,
        BorderRadius,
        RoundedRectangleBorder,
        Row,
        Icons,
        Icon,
        SizedBox,
        ElevatedButton;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uffmobileplus/app/data/services/device_service.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';
import 'package:uffmobileplus/app/data/services/foreground_service.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class MonitoraUffController extends GetxController with WidgetsBindingObserver {
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
  final hasWhenInUseLocationPermission = false.obs;
  final hasAlwaysLocationPermission = false.obs;
  final hasNotificationPermission = false.obs;
  //final isLocationServiceEnabled = false.obs;

  void centerMapOnCurrentLocation() {
    try {
      mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      if (kDebugMode) print('Error moving map: $e');
    }
  }

  /// Esta função realiza trabalho quando o usuário volta para o aplicativo
  /// após ter saído do mesmo (neste caso, quando ele volta das configurações).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      hasAlwaysLocationPermission.value =
          await Permission.locationAlways.isGranted;
      hasNotificationPermission.value = await Permission.notification.isGranted;
    }
  }

  @override
  Future<void> onInit() async {
    // Getx irá automaticamente atualizar 'firebaseUsers' sempre que os
    // documentos forem atualizados na nuvem
    WidgetsBinding.instance.addObserver(this);

    firebaseUsers.bindStream(FirebaseProvider().getAllUsers());
    super.onInit();

    mapController = MapController();
    deviceId = (await DeviceService.getBuildNumber()).toString();
    _externalModulesServices = Get.find<ExternalModulesServices>();
    await _externalModulesServices.initialize();
    hasWhenInUseLocationPermission.value =
        await Permission.locationWhenInUse.isGranted;
    hasAlwaysLocationPermission.value =
        await Permission.locationAlways.isGranted;
    hasNotificationPermission.value = await Permission.notification.isGranted;
    isTrackingEnabled.value = await _service.isRunning();
  }

  /// Método utilizado para escolher a cor dos pins, determinando uma cor
  /// especial para o pin correspondente à localização do próprio usuário
  /// e outra para os demais.
  Color setMarkerColor(UserLocationModel someUser) {
    String currentUserId = _externalModulesServices.getUserIdUFF();
    return someUser.iduff == currentUserId ? Colors.indigo : Colors.lightBlue;
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

  Future<void> notifyGpsDisabled() async {
    await Get.dialog(
      AlertDialog(
        title: Text("O GPS está desativado"),
        content: Text("Por favor, ative o GPS para continuar."),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.darkBlue()),
            child: Text("ENTENDI"),
            onPressed: () {
              Get.back(); // Fecha o diálogo
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _startService() async {
    // Verifica se GPS está ativado.
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      notifyGpsDisabled();
      return; // Interrompe a execução para não iniciar o serviço sem GPS
    }

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

    // Atualiza UI (botão).
    isTrackingEnabled.value = true;
    // Informa Firebase que sua posição pode ser visualizada no mapa.
    FirebaseProvider().updateIsTracked(deviceId, true);
  }

  Future<void> _stopService() async {
    _service.invoke("stopService");
    isTrackingEnabled.value = false;
    FirebaseProvider().updateIsTracked(deviceId, false);
  }

  Future<void> requestWhenInUsePermission() async {
    await Permission.locationWhenInUse.request();
    hasWhenInUseLocationPermission.value =
        await Permission.locationWhenInUse.isGranted;
  }

  Future<void> requestAlwaysPermission() async {
    PermissionStatus locationWhenInUseStatus = await Permission
        .locationWhenInUse
        .request();

    if (locationWhenInUseStatus.isGranted) {
      bool userAgreed = await _showBackgroundDisclosure();

      if (userAgreed) {
        PermissionStatus locationAlwaysStatus = await Permission.locationAlways
            .request();

        if (locationAlwaysStatus.isPermanentlyDenied) openAppSettings();
      }
    } else if (locationWhenInUseStatus.isPermanentlyDenied) {
      openAppSettings(); // TODO: Esse bloco não está funcionando como deveria.
    }
  }

  /// Precisamos de permissão para exibibir notificações pois serviços de
  /// localização em segundo plano são críticos tanto para a privacidade do
  /// usuário quanto para o consumo de bateria. Sem notificações, o SO pode
  /// matar esses serviços.
  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
    hasNotificationPermission.value = await Permission.notification.isGranted;
  }

  /// Verifica se todas as permissões necessárias para o monitora funcionar
  /// adequadamente já foram concedidas ao aplicativo pelo usuário.
  bool arePermissionsGranted() {
    return hasAlwaysLocationPermission.value && hasNotificationPermission.value;
  }

  /// Aviso requerido pela Google Play.
  Future<bool> _showBackgroundDisclosure() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            title: Row(
              children: [
                Icon(Icons.security, color: AppColors.darkBlue()),
                const SizedBox(width: 10),
                const Text("Atenção"),
              ],
            ),
            content: const Text(
              "O Monitora UFF deseja coletar dados de localização mesmo quando o aplicativo estiver fechado ou não estiver em uso.\n\n"
              "Esses dados permitem que os supervisores visualizem sua posição em tempo real.\n\n"
              "Como ativar:\n"
              "1. Toque em 'Prosseguir'.\n"
              "2. Em Permissões > Localização.\n"
              "3. Selecione 'Permitir o tempo todo'.",
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkBlue(),
                ),
                child: Text("AGORA NÃO"),
              ),
              TextButton(
                onPressed: () async {
                  Get.back(result: true);
                  // 3. Abre as configurações do sistema diretamente na página do App
                  await openAppSettings();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkBlue(),
                ),
                child: const Text("PROSSEGUIR"),
              ),
            ],
          ),
          barrierDismissible: false, // Impede fechar clicando fora
        ) ??
        false;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    mapController.dispose();
    super.onClose();
  }
}
