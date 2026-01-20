import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uffmobileplus/firebase_options_tracking.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

@pragma('vm:entry-point')
class LocationService {
  static const String notificationChannelId = 'location_tracking_channel';
  static const int notificationId = 888;

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Configuração da Notificação
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'Location Tracking', // título
      description: 'Este canal é usado para notificações de rastreamento de localização.', // descrição
      importance: Importance.low, // a importância deve ser baixa ou superior
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // isso será executado quando o app estiver em primeiro ou segundo plano em um isolate separado
        onStart: onStart,

        // iniciar serviço automaticamente
        autoStart: false, 
        isForegroundMode: true,

        notificationChannelId: notificationChannelId, // isso deve coincidir com o canal de notificação criado acima.
        initialNotificationTitle: 'Monitora UFF',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        // iniciar serviço automaticamente
        autoStart: false,

        // isso será executado quando o app estiver em primeiro plano em um isolate separado
        onForeground: onStart,

        // você tem que habilitar o recurso de 'background fetch' no projeto xcode
        onBackground: onIosBackground,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Disponível apenas para flutter 3.0.0 e posteriores
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicializar FLNP para lidar com ações no isolate de segundo plano
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Inicializar Firebase no isolate de segundo plano
  try {
    await Firebase.initializeApp(
      name: 'tracking',
      options: FirebaseOptionsTracking.currentPlatform,
    );
    print("LocationService: Firebase initialized in background");
  } catch (e) {
    print("LocationService: Firebase initialization error: $e");
  }
  
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: initializationSettingsAndroid),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
       // Tratar payload (toque no corpo) ou actionId (toque no botão)
       if (response.payload == 'disable_tracking' || response.actionId == 'disable_tracking') {
           service.invoke('stopTracking');
       } else if (response.payload == 'enable_tracking' || response.actionId == 'enable_tracking') {
           service.invoke('startTracking');
       }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  
  // Gerenciar estado
  bool isTracking = false;

  StreamSubscription<Position>? positionStream;
  Timer? uploadTimer;
  Position? currentPosition;
  String? currentMatricula; // Store matricula
  String? currentName; // Store name


  service.on('startTracking').listen((event) async {
      if(isTracking) return;
      
      if (event != null) {
        currentMatricula = event['matricula'];
        currentName = event['name'];
        print('LocationService: Received user info: $currentName ($currentMatricula)');
      }

      isTracking = true;
      await updateNotification(flutterLocalNotificationsPlugin, true);

      // Obter ID do Dispositivo (mantido como fallback ou info adicional)
      String deviceId = 'unknown_device';
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id; 
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
        }
      } catch (e) {
        print('LocationService: Error getting device info: $e');
        deviceId = 'error_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Use Matricula as the primary validation/ID if available
      String trackingId = currentMatricula ?? deviceId;
      print('LocationService: Using Tracking ID: $trackingId');

      // Atualização imediata de status no Firestore (APENAS Status)
      try {
           final FirebaseApp app = await _getTrackingApp();
           final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
           await firestore.collection('live_locations').doc(trackingId).set({
               'isMonitored': true,
               'timestamp': FieldValue.serverTimestamp(),
               'deviceId': deviceId, // Keep physical device ID for reference
               'matricula': currentMatricula,
               'name': currentName,
           }, SetOptions(merge: true));
           print('LocationService: Marked as monitored immediately for $trackingId');
      } catch (e) {
           print('LocationService: Error marking as monitored immediately: $e');
      }

      bool isFirstLocation = true; // Flag for first location

      // Iniciar Stream de Geolocalização para atualizações de UI
      LocationSettings locationSettings;
      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 15, // Distância mínima (metros)
          // forceLocationManager: true, // Removed to use FusedLocationProvider for better stability
          intervalDuration: const Duration(seconds: 5), // Tempo mínimo entre atualizações
        );
      } else if (Platform.isIOS || Platform.isMacOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 15,
          pauseLocationUpdatesAutomatically: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        );
      }

      positionStream = Geolocator.getPositionStream(
          locationSettings: locationSettings)
          .listen((Position? position) {
        if (position != null) {
          

          currentPosition = position;
          service.invoke(
            'updateLocation',
            {
              'lat': position.latitude,
              'lng': position.longitude,
            },
          );
          
          if (isFirstLocation) {
              _uploadLocation(trackingId, deviceId, currentMatricula, currentName, position);
              isFirstLocation = false;
          }
        }
      });

      // Iniciar Timer de Envio Periódico (a cada 30 segundos)
      uploadTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
          if (currentPosition != null) {
             await _uploadLocation(trackingId, deviceId, currentMatricula, currentName, currentPosition!);
          }
      });
       
      service.invoke('trackingStatus', {'isTracking': true});
  });

  service.on('stopTracking').listen((event) async {
       try {
           final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
           String deviceId = 'unknown_device';
            if (Platform.isAndroid) {
              AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
              deviceId = androidInfo.id;
            } else if (Platform.isIOS) {
              IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
              deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
            }
           
           // If we have a stored matricula, use it. Otherwise, we might have a problem if the service restarted?
           // Ideally we should persist it, but for now rely on memory. 
           // If memory lost (service restart), we might fail to update the correct doc if it was matricula-based.
           // However, stopTracking usually comes from UI which might re-send data? No, it's just a signal.
           // Let's use the local 'currentMatricula' if available.
           
           String trackingId = currentMatricula ?? deviceId;

           final FirebaseApp app = await _getTrackingApp();
           final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
           await firestore.collection('live_locations').doc(trackingId).set({
               'isMonitored': false,
               'timestamp': FieldValue.serverTimestamp(),
           }, SetOptions(merge: true));
           print('LocationService: Marked as not monitored for $trackingId');
       } catch (e) {
           print('LocationService: Error marking as not monitored: $e');
       }

       isTracking = false;
       positionStream?.cancel();
       uploadTimer?.cancel();
       await updateNotification(flutterLocalNotificationsPlugin, false);
       service.invoke('trackingStatus', {'isTracking': false});
  });

  service.on('requestUpdate').listen((event) {
      service.invoke('trackingStatus', {'isTracking': isTracking});
      if (currentPosition != null && isTracking) {
          service.invoke(
            'updateLocation',
            {
              'lat': currentPosition!.latitude,
              'lng': currentPosition!.longitude,
            },
          );
      }
  });
  
  // Estado Inicial
  await updateNotification(flutterLocalNotificationsPlugin, false);
}

// Helper para atualizar a notificação
Future<void> updateNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, bool tracking) async {
  await flutterLocalNotificationsPlugin.show(
    LocationService.notificationId,
    'Monitora UFF',
    tracking ? 'Tracking Active' : 'Tracking Paused',
    NotificationDetails(
      android: AndroidNotificationDetails(
        LocationService.notificationChannelId,
        'Location Tracking',
        icon: '@mipmap/ic_launcher',
        ongoing: true, // Necessário para manter o serviço ativo em primeiro plano
        actions: [
           if (tracking)
             const AndroidNotificationAction('disable_tracking', 'Disable', showsUserInterface: false, cancelNotification: false)
           else
             const AndroidNotificationAction('enable_tracking', 'Enable', showsUserInterface: false, cancelNotification: false)
        ],
      ),
    ),
    payload: tracking ? 'disable_tracking' : 'enable_tracking', // Payload para o toque
  );
}

// Helper para enviar a localização
Future<void> _uploadLocation(String trackingId, String physicalDeviceId, String? matricula, String? name, Position position) async {
  try {
    final FirebaseApp app = await _getTrackingApp();
    final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
    
    // 1. Adicionar ao histórico
    await firestore.collection('locations').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'deviceId': physicalDeviceId, // Historical record keeps physical device ID
      'matricula': matricula,
      'name': name,
      'trackingId': trackingId,
    });

    // 2. Atualizar localização em tempo real
    await firestore.collection('live_locations').doc(trackingId).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'deviceId': physicalDeviceId,
      'matricula': matricula,
      'name': name,     
      'isMonitored': true,
    }, SetOptions(merge: true));

    print('LocationService: Location uploaded for $trackingId: ${position.latitude}, ${position.longitude}');
  } catch (e) {
    print('LocationService: Error uploading location: $e');
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Inicializar plugins se necessário
  DartPluginRegistrant.ensureInitialized();
  
  final service = FlutterBackgroundService();
  if (notificationResponse.actionId == 'disable_tracking') {
     service.invoke('stopTracking');
  } else if (notificationResponse.actionId == 'enable_tracking') {
     service.invoke('startTracking');
  }
}

// Helper para obter ou inicializar o Firebase App com segurança
Future<FirebaseApp> _getTrackingApp() async {
  try {
    return Firebase.app('tracking');
  } catch (e) {
    // Se não encontrado, tentar inicializar
    return await Firebase.initializeApp(
      name: 'tracking',
      options: FirebaseOptionsTracking.currentPlatform,
    );
  }
}
