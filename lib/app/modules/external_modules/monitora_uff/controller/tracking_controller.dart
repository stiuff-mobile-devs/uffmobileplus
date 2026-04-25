import 'dart:async';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show Colors, WidgetsBindingObserver, AlertDialog, Text, TextButton;
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/user_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/location_point.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_model.dart';
import 'package:uffmobileplus/app/data/services/foreground_service.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class TrackingController extends GetxController with WidgetsBindingObserver {
  final FlutterBackgroundService _service = FlutterBackgroundService();
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
  RxList<UserModel> firebaseUsers = <UserModel>[].obs;
  final Rxn<UserModel> selectedFirebaseUser = Rxn<UserModel>();
  late final MapController mapController;
  final isTrackingEnabled = false.obs;
  final UserController userCtrl = Get.find<UserController>();
  final Rx<double?> heading = Rx<double?>(null);
  StreamSubscription<CompassEvent>? _compassSubscription;

  /// Trajetória recente do usuário focado (aquele cuja barra inferior está visível).
  final RxList<LocationPoint> selectedTrajectory = <LocationPoint>[].obs;
  StreamSubscription<List<LocationPoint>>? _trajectorySubscription;
  Future<void> centerMapOnCurrentLocation() async {
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

    super.onInit();
    mapController = MapController();
    firebaseUsers.bindStream(FirebaseProvider().getAllTrackedUsers());

    try {
      _compassSubscription = FlutterCompass.events?.listen((event) {
        heading.value = event.heading;
      });
    } catch (e) {
      if (kDebugMode) print('Compass not available or error: $e');
    }

    // TODO: encapsular em um método
    if (userCtrl.isMonitor()) {
      position = await Geolocator.getCurrentPosition();
    }

    isTrackingEnabled.value = await _service.isRunning();
  }

  /// Método utilizado para escolher a cor dos pins, determinando uma cor
  /// especial para o pin correspondente à localização do próprio usuário
  /// e outra para os demais.
  Color setMarkerColor(UserModel someUser) {
    final currentUserEmail = userCtrl.user?.email;

    return someUser.email == currentUserEmail
        ? Colors.indigo
        : Colors.lightBlue;
  }

  void openFirebaseUserDetails(UserModel user) {
    selectedFirebaseUser.value = user;

    // Cancelar listener anterior (se houver) e iniciar um novo para
    // o usuário focado.
    _trajectorySubscription?.cancel();
    selectedTrajectory.clear();
    _trajectorySubscription = FirebaseProvider()
        .getRecentTrajectory(user.email)
        .listen((points) {
      selectedTrajectory.value = points;
    });
  }

  void closeFirebaseUserDetails() {
    selectedFirebaseUser.value = null;

    _trajectorySubscription?.cancel();
    _trajectorySubscription = null;
    selectedTrajectory.clear();
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
        initialNotificationTitle: "UM+: Monitoramento de jornada ativo",
        initialNotificationContent:
            "O monitoramento está ligado. Certifique-se de desativá-lo assim que terminar suas atividades.",
      ),
    );
  }

  // TODO: mover para permissions controller.
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
    _service.on('ready').listen((event) async {
      _service.invoke("setUserInfo", {
        "email": userCtrl.user!.email,
        "name": userCtrl.getUserName(),
        "funcao": userCtrl.user!.funcao, //_currentUser.funcao,
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
    FirebaseProvider().updateIsTracked(userCtrl.user!.email, true);
  }

  Future<void> _stopService() async {
    _service.invoke("stopService");
    isTrackingEnabled.value = false;
    FirebaseProvider().updateIsTracked(userCtrl.user!.email, false);
  }

  @override
  void onClose() {
    _compassSubscription?.cancel();
    _trajectorySubscription?.cancel();
    mapController.dispose();
    super.onClose();
  }



  Future<void> launchGoogleMeet(String email) async {
    await Clipboard.setData(ClipboardData(text: email));

    final intent = AndroidIntent(
      //action: 'action_view',
      action: 'android.intent.action.MAIN',
      //data: url,
      package: 'com.google.android.apps.tachyon', // Google Meet standalone
    );

    try {
      await intent.launch();
    } catch (e) {
      if (kDebugMode) {
        print('Não foi possível abrir o Google Meet standalone: $e');
      }
    }
  }
}
