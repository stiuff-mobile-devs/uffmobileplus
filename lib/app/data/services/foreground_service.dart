import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uffmobileplus/app/data/services/device_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';
import 'package:uffmobileplus/firebase_options_tracking.dart';

//Timer? _locationTimer;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp(
    name: 'tracking',
    options: FirebaseOptionsTracking.currentPlatform,
  );

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('setUserInfo').listen((event) {
    if (event != null) {
      updateLocation(service, event['id'], event['name']);
    }
  });

  // TODO: usar shared preferences?
  service.invoke('ready');
}

void updateLocation(ServiceInstance service, String iduff, String name) {
  // Configuração do GPS
  final androidSettings = AndroidSettings(
    accuracy: LocationAccuracy.high, // TODO: testar outros valores aqui
    distanceFilter: 10, // Só atualiza se mover mais de 10 metros
    intervalDuration: Duration(seconds: 5),
    foregroundNotificationConfig: ForegroundNotificationConfig(
      notificationTitle: "UFF Mobile Plus",
      notificationText: "Sua posição está sendo monitorada.",
      enableWakeLock: true, // TODO: ler a descrição deste atributo.
    ),
  );

  // TODO: configurar IOSSettings

  // TODO: adicionar condição aqui para saber se serviço é Android ou IOS e seleciona a configuração correta;

  // TODO: trocar androidSettings por locationSettings
  Geolocator.getPositionStream(locationSettings: androidSettings).listen((
    Position position,
  ) async {
    print("\n\n${position.accuracy}\n\n");
    // TODO: Filtro de precisão: Se o erro for maior que 20 metros, ignorar
    // e.g.: if (position.accuracy > 20) return;

    String deviceId = (await DeviceService.getBuildNumber()).toString();

    // Atualiza firebase
    if (await FirebaseProvider().doesDocumentExist(deviceId)) {
      await FirebaseProvider().updateLocationAndTimestamp(
        deviceId,
        position.latitude,
        position.longitude,
        DateTime.now(),
      );
    } else {
      await FirebaseProvider().adicionarDados(
        UserLocationModel(
          id: deviceId,
          lat: position.latitude,
          lng: position.longitude,
          timestamp: DateTime.now(),
          nome: name,
          iduff: iduff,
          isTracked: true,
        ),
      );
    }

    // Envia para o app principal
    service.invoke('updateLocationLocally', {'position': position});
  });
}

//void updateLocation(ServiceInstance service, String iduff, String name) {
//  _locationTimer?.cancel();
//  _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//    Position position = await Geolocator.getCurrentPosition(
//      locationSettings: LocationSettings(
//        accuracy: LocationAccuracy.high,
//      ),
//    );
//
//    if (service is AndroidServiceInstance) {
//      if (await service.isForegroundService()) {
//        service.setForegroundNotificationInfo(
//          title: "ATENÇÃO: monitoramento ativo",
//          content: "Entre no UFF Mobile Plus e desative-o quando necessário!",
//        );
//      }
//    }
//
//    String deviceId = (await DeviceService.getBuildNumber()).toString();
//
//    if (await FirebaseProvider().doesDocumentExist(deviceId)) {
//      await FirebaseProvider().updateLocationAndTimestamp(
//        deviceId,
//        position.latitude,
//        position.longitude,
//        DateTime.now(),
//      );
//    } else {
//      await FirebaseProvider().adicionarDados(
//        UserLocationModel(
//          id: deviceId,
//          lat: position.latitude,
//          lng: position.longitude,
//          timestamp: DateTime.now(),
//          nome: name,
//          iduff: iduff,
//          isTracked: true,
//        ),
//      );
//    }
//
//    // Envia para o app principal
//    service.invoke('updateLocationLocally', {
//      'position': position
//    });
//  });
//}
