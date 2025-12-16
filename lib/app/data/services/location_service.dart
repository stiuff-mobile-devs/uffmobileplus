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

    // Notification Setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'Location Tracking', // title
      description: 'This channel is used for location tracking notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: false, 
        isForegroundMode: true,

        notificationChannelId: notificationChannelId, // this must match with notification channel you created above.
        initialNotificationTitle: 'Monitora UFF',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
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
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize FLNP to handle actions in the background isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Initialize Firebase in background isolate
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
       // Handle payload (body tap) or actionId (button tap)
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
  
  // Manage state
  bool isTracking = false;

  StreamSubscription<Position>? positionStream;
  Timer? uploadTimer;
  Position? currentPosition;

  // Helper to safely get or initialize the Firebase App
  Future<FirebaseApp> _getTrackingApp() async {
      try {
          return Firebase.app('tracking');
      } catch (e) {
          // If not found, try to initialize
          return await Firebase.initializeApp(
              name: 'tracking',
              options: FirebaseOptionsTracking.currentPlatform,
          );
      }
  }

  // Helper to update notification
  Future<void> updateNotification(bool tracking) async {
      await flutterLocalNotificationsPlugin.show(
        LocationService.notificationId,
        'Monitora UFF',
        tracking ? 'Tracking Active' : 'Tracking Paused',
        NotificationDetails(
          android: AndroidNotificationDetails(
            LocationService.notificationChannelId,
            'Location Tracking',
            icon: '@mipmap/ic_launcher',
            ongoing: true, // Required to keep service alive in FG
            actions: [
               if (tracking)
                 const AndroidNotificationAction('disable_tracking', 'Disable', showsUserInterface: false, cancelNotification: false)
               else
                 const AndroidNotificationAction('enable_tracking', 'Enable', showsUserInterface: false, cancelNotification: false)
            ],
          ),
        ),
        payload: tracking ? 'disable_tracking' : 'enable_tracking', // Payload for tap
      );
  }

  // Helper to upload location
  Future<void> _uploadLocation(String deviceId, Position position) async {
       try {
           final FirebaseApp app = await _getTrackingApp();
           final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
           
           // 1. Add to history (existing logic)
           await firestore.collection('locations').add({
             'latitude': position.latitude,
             'longitude': position.longitude,
             'timestamp': FieldValue.serverTimestamp(),
             'deviceId': deviceId, 
           });

           // 2. Update live location (new logic)
           await firestore.collection('live_locations').doc(deviceId).set({
               'latitude': position.latitude,
               'longitude': position.longitude,
               'timestamp': FieldValue.serverTimestamp(),
               'deviceId': deviceId,
               'isMonitored': true,
           }, SetOptions(merge: true));

           print('LocationService: Location uploaded for $deviceId: ${position.latitude}, ${position.longitude}');
       } catch (e) {
           print('LocationService: Error uploading location: $e');
       }
  }

  service.on('startTracking').listen((event) async {
      if(isTracking) return;
      isTracking = true;
      await updateNotification(true);

      // Get Device ID
      String deviceId = 'unknown_device';
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id; // Unique ID on Android
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
        }
      } catch (e) {
        print('LocationService: Error getting device info: $e');
        deviceId = 'error_${DateTime.now().millisecondsSinceEpoch}';
      }
      print('LocationService: Using Device ID: $deviceId');

      // Immediate status update to Firestore (Status ONLY)
      try {
           final FirebaseApp app = await _getTrackingApp();
           final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
           await firestore.collection('live_locations').doc(deviceId).set({
               'isMonitored': true,
               'timestamp': FieldValue.serverTimestamp(),
               'deviceId': deviceId,
           }, SetOptions(merge: true));
           print('LocationService: Marked as monitored immediately for $deviceId');
      } catch (e) {
           print('LocationService: Error marking as monitored immediately: $e');
      }

      bool isFirstLocation = true; // Flag for first location

      // Start Geolocation Stream for UI updates
      positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high, distanceFilter: 10))
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
              _uploadLocation(deviceId, position);
              isFirstLocation = false;
          }
        }
      });

      // Start Periodic Upload Timer (every 30 seconds)
      uploadTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
          if (currentPosition != null) {
             await _uploadLocation(deviceId, currentPosition!);
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

           final FirebaseApp app = await _getTrackingApp();
           final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
           await firestore.collection('live_locations').doc(deviceId).set({
               'isMonitored': false,
               'timestamp': FieldValue.serverTimestamp(),
           }, SetOptions(merge: true));
           print('LocationService: Marked as not monitored for $deviceId');
       } catch (e) {
           print('LocationService: Error marking as not monitored: $e');
       }

       isTracking = false;
       positionStream?.cancel();
       uploadTimer?.cancel();
       await updateNotification(false);
       service.invoke('trackingStatus', {'isTracking': false});
  });
  
  // Initial State
  await updateNotification(false);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Initialize plugins if needed
  DartPluginRegistrant.ensureInitialized();
  
  final service = FlutterBackgroundService();
  if (notificationResponse.actionId == 'disable_tracking') {
     service.invoke('stopTracking');
  } else if (notificationResponse.actionId == 'enable_tracking') {
     service.invoke('startTracking');
  }
}
