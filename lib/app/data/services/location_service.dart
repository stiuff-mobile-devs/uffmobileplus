import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uffmobileplus/firebase_options_tracking.dart';
import 'dart:io';

// Neste arquivo: funções sem @pragma('vm:entry-point') são helpers
// funções com @pragma('vm:entry-point') são executadas em um isolate separado

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
  String? currentIdUFF; // Store iduff
  String? currentName; // Store name


      service.on('startTracking').listen((event) async {
      if(isTracking) return;
      
      if (event != null) {
        currentIdUFF = event['iduff'];
        currentName = event['name'];
        print('LocationService: Received user info: $currentName ($currentIdUFF)');
      }

      if (currentIdUFF == null || currentIdUFF!.isEmpty) {
        print('LocationService: ERROR - Missing iduff. Cannot start tracking.');
        return;
      }
      
      String trackingId = currentIdUFF!;
      
      isTracking = true;
      await updateNotification(flutterLocalNotificationsPlugin, true);

      
      print('LocationService: Using Tracking ID: $trackingId');

      // Atualização imediata de status no Firestore (APENAS Status)
      try {
           final FirebaseApp app = await _getTrackingApp();
           final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
           await firestore.collection('live_locations').doc(trackingId).set({
               'isMonitored': true,
               'timestamp': FieldValue.serverTimestamp(),
               'iduff': currentIdUFF,
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
              _uploadLocation(trackingId, currentIdUFF, currentName, position);
              isFirstLocation = false;
          }
        }
      });

      // Iniciar Timer de Envio Periódico (a cada 30 segundos)
      uploadTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
          if (currentPosition != null) {
             await _uploadLocation(trackingId, currentIdUFF, currentName, currentPosition!);
          }
      });
       
      service.invoke('trackingStatus', {'isTracking': true});
  });

  service.on('stopTracking').listen((event) async {
           String trackingId = currentIdUFF ?? 'unknown';
           if (trackingId == 'unknown') {
              print('LocationService: Error - No tracking ID found during stopTracking');
           }

           try {
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
Future<void> _uploadLocation(String trackingId, String? iduff, String? name, Position position) async {
  try {
    final FirebaseApp app = await _getTrackingApp();
    final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
    
    // 1. Adicionar ao histórico
    await firestore.collection('locations').add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'iduff': iduff,
      'name': name,
      'trackingId': trackingId,
    });

    // 2. Atualizar localização em tempo real
    await firestore.collection('live_locations').doc(trackingId).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'iduff': iduff,
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
