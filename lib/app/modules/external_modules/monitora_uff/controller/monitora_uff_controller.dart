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

class MonitoraUffController extends GetxController {
  final RxBool isGathering = false.obs;
  final RxString coordinates = 'Lat: -, Long: -'.obs;
  
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null);
  final MapController mapController = MapController();
  final RxList<Marker> remoteMarkers = <Marker>[].obs;
  String? myDeviceId;

  StreamSubscription? _serviceSubscription; // Listen to service updates

  @override
  void onInit() {
    super.onInit();
    _fetchDeviceId();
    _connectToService();
    _listenToRemoteLocations();
  }



  @override
  void onClose() {
    _serviceSubscription?.cancel();
    super.onClose();
  }

  void _connectToService() {
    final service = FlutterBackgroundService();
    
    // Listen for updates from the service
    _serviceSubscription = service.on('updateLocation').listen((event) {
        if (event != null && event['lat'] != null && event['lng'] != null) {
            double lat = event['lat'];
            double lng = event['lng'];
            
            coordinates.value = 'Lat: ${lat.toStringAsFixed(4)}, Long: ${lng.toStringAsFixed(4)}';
            currentPosition.value = LatLng(lat, lng);
            // mapController.move(LatLng(lat, lng), 15); // Optional follow
        }
    });

    service.on('trackingStatus').listen((event) {
        if (event != null && event['isTracking'] != null) {
            isGathering.value = event['isTracking'];
            if (isGathering.value == false) {
                currentPosition.value = null;
                coordinates.value = 'Lat: -, Long: -';
            }
        }
    });

    service.isRunning().then((running) {
        isGathering.value = running;
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
      // Use the default app instance or ensure we are using the correct one if named.
      // Since LocationService uses 'tracking' app, we should probably check if main app uses default or tracking.
      // Usually main app uses default. Let's assume we can access the 'tracking' app if initialized or default.
      // Ideally, the main app should initialize Firebase. If it's initialized, we can access it.
      // If 'tracking' app is only in background isolate, we might need to seek safety.
      // But typically we use default instance in UI. Let's try default first.
      
      FirebaseFirestore.instance.collection('live_locations').snapshots().listen((snapshot) {
          remoteMarkers.clear();
          for (var doc in snapshot.docs) {
              final data = doc.data();
              final String? deviceId = data['deviceId'];
              final bool? isMonitored = data['isMonitored'];

              // Debug Print
              print('Controller: Me: $myDeviceId | Remote: $deviceId | isMonitored: $isMonitored | hasLoc: ${data['latitude'] != null}');

              // Skip if it is me
              if (deviceId == myDeviceId) continue;

              if (isMonitored != true) continue;

              final double? lat = data['latitude'];
              final double? lng = data['longitude'];

              if (lat != null && lng != null) {
                  remoteMarkers.add(
                      Marker(
                          point: LatLng(lat, lng),
                          width: 80,
                          height: 80,
                          child: Icon(Icons.location_pin, color: Colors.blueAccent, size: 40),
                      ),
                  );
              }
          }
      });
  }

  void toggleGathering(bool value) async {
    final service = FlutterBackgroundService();
    if (value) {
      bool hasPermission = await _handlePermission();
      if (!hasPermission) {
          isGathering.value = false;
          return;
      }
      // Ensure service is running before invoking
      if (!(await service.isRunning())) {
        await service.startService();
        // Wait for the background isolate to initialize and register listeners
        await Future.delayed(const Duration(seconds: 2));
      }
      service.invoke('startTracking');
    } else {
      service.invoke('stopTracking');
      // Optionally stop the service entirely if we want to clear notification
      // service.invoke('stopService'); 
    }
    isGathering.value = value;
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return false;
    } 

    return true;
  }

  // Removed direct Geolocator streams as they are now in the service
}
