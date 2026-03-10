import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/firebase_options_tracking.dart';

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
      updateLocation(service, event['email'], event['name'], event['funcao']);
    }
  });

  // TODO: usar shared preferences?
  service.invoke('ready');
}

// TODO: passar UserModel para essa função em vez de email, nome.
void updateLocation(ServiceInstance service, String email, String name, String funcao) {
  // Configuração do GPS
  final androidSettings = AndroidSettings(
    accuracy: LocationAccuracy.high, // TODO: testar outros valores aqui
    distanceFilter: 10, // Só atualiza se mover mais de 10 metros
    intervalDuration: Duration(seconds: 5),
    //foregroundNotificationConfig: ForegroundNotificationConfig(
    //  notificationTitle: "UFF Mobile Plus",
    //  notificationText: "Sua posição está sendo monitorada.",
    //  enableWakeLock: true, // TODO: ler a descrição deste atributo.
    //),
  );

  // TODO: configurar IOSSettings

  // TODO: adicionar condição aqui para saber se serviço é Android ou IOS e seleciona a configuração correta;

  // TODO: trocar androidSettings por locationSettings
  Geolocator.getPositionStream(locationSettings: androidSettings).listen((
    Position position,
  ) async {
    // print("\n\n${position.accuracy}\n\n");
    // TODO: Filtro de precisão: Se o erro for maior que 20 metros, ignorar
    // e.g.: if (position.accuracy > 20) return;

    // Atualiza firebase 
    if (await FirebaseProvider().doesDocumentExist(email)) {
      await FirebaseProvider().updateLocationAndTimestamp(
        email: email,
        nome: name,
        funcao: funcao,
        lat: position.latitude,
        lng: position.longitude,
        timestamp: DateTime.now(),
      );
    } 

    // Envia para o app principal
    service.invoke('updateLocationLocally', {'position': position});
  });
}
