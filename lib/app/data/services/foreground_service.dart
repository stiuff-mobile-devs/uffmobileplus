import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/firebase_options_harpia.dart';
import 'package:uffmobileplus/firebase_options_uffmobileplus.dart';

Timer? _heartbeatTimer;
StreamSubscription<Position>? _positionSubscription;
int interval = 5;
int distance = 10;
int heartbeatInterval = 5;

int _consecutivePermissionErrors = 0;
const int _maxConsecutivePermissionErrors = 3;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp(
    name: 'uffmobileplus',
    options: FirebaseOptionsUffmobileplus.currentPlatform,
  );

  await Firebase.initializeApp(
    name: 'harpia',
    options: FirebaseOptionsHarpia.currentPlatform,
  );

  // Verificar e atualizar o token no isolate de background
  final harpiaAuth = fb.FirebaseAuth.instanceFor(app: Firebase.app('harpia'));
  final currentUser = harpiaAuth.currentUser;
  if (currentUser != null) {
    try {
      await currentUser.getIdToken(true);
      debugPrint(
        '[ForegroundService] Auth Harpia disponível no background: ${currentUser.email}',
      );
    } catch (e) {
      debugPrint('[ForegroundService] Erro ao refresh token Harpia: $e');
    }
  } else {
    debugPrint(
      '[ForegroundService] AVISO: currentUser Harpia é nulo no background isolate.',
    );
  }

  service.on('stopService').listen((event) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    service.stopSelf();
  });

  service.on('setUserInfo').listen((event) async {
    if (event != null) {
      await updateLocation(service, event['email'], event['name']);
    }
  });

  service.invoke('ready');
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// TODO: passar UserModel para essa função em vez de email, nome.
Future<void> updateLocation(ServiceInstance service, String email, String name) async {
  // Configuração do GPS
  late LocationSettings locationSettings;

  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distance, // Só atualiza se mover mais de `distance` metros
      intervalDuration: Duration(minutes: interval),
    );
  } else if (Platform.isIOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.other,
      distanceFilter: distance,
      pauseLocationUpdatesAutomatically: true,
      showBackgroundLocationIndicator: true,
    );
  } else {
    locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distance,
    );
  }

  _heartbeatTimer?.cancel();
  _heartbeatTimer = Timer.periodic(Duration(minutes: heartbeatInterval), (timer) async {
    try {
      if (await FirebaseProvider().doesDocumentExist(email)) {
        await FirebaseProvider().updateHeartbeat(email);
      }
    } catch (e) {
      debugPrint('[ForegroundService] Erro no heartbeat: $e');
    }
  });

  await _positionSubscription?.cancel();
  _positionSubscription = Geolocator.getPositionStream(
    locationSettings: locationSettings,
  ).listen((Position position) async {
    // Se muitos erros de permissão consecutivos, interromper tentativas temporariamente
    if (_consecutivePermissionErrors >= _maxConsecutivePermissionErrors) {
      debugPrint(
        '[ForegroundService] Muitos erros de permissão consecutivos ($_consecutivePermissionErrors). Parando tentativas de escrita.',
      );
      return;
    }

    // Atualiza firebase 
    try {
      if (await FirebaseProvider().doesDocumentExist(email)) {
        await FirebaseProvider().updateLocationAndTimestamp(
          email: email,
          nome: name,
          lat: position.latitude,
          lng: position.longitude,
          timestamp: DateTime.now(),
        );
        _consecutivePermissionErrors = 0;
      }
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        _consecutivePermissionErrors++;
        debugPrint(
          '[ForegroundService] PERMISSION_DENIED ao atualizar localização ($_consecutivePermissionErrors/$_maxConsecutivePermissionErrors). Tentando renovar token...',
        );
        try {
          final harpiaAuth = fb.FirebaseAuth.instanceFor(app: Firebase.app('harpia'));
          await harpiaAuth.currentUser?.getIdToken(true);
        } catch (_) {}
      } else {
        debugPrint('[ForegroundService] Erro ao atualizar localização: $e');
      }
    }

    // Envia para o app principal
    service.invoke('updateLocationLocally', {'position': position});
  });
}
