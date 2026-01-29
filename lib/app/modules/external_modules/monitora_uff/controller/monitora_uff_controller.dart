import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/location_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';

class MonitoraUffController extends GetxController {
  Rx<Position?> currentLocation = Rx<Position?>(null);
  RxList<UserLocationModel> firebaseUsers = <UserLocationModel>[].obs;
  late final MapController mapController;
  late LocationService locationService;
  Rx<Position?> get position => locationService.position;
  RxBool isTrackingEnabled = RxBool(true);

  void centerMapOnCurrentLocation() {
    final pos = position.value;
    if (pos == null) return;

    try {
      mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
    } catch (e) {
      if (kDebugMode) {
        print('Error moving map: $e');
      }
    }
  }

  @override
  void onInit() {
    // Getx irá automaticamente atualizar 'firebaseUsers' sempre que os
    // documentos forem atualizados na nuvem
    firebaseUsers.bindStream(FirebaseProvider().getAllUsers());
    locationService = Get.find<LocationService>();
    locationService.init();
    mapController = MapController();
    //isTrackingEnabled = locationService.isTracking as RxBool;

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }

  Future<void> toggleTracking() async {
    if (isTrackingEnabled.value) {
      locationService.stopTracking();
    } else {
      locationService.startTracking();
    }
    // TODO: por ser uma variável reativa, talvez essa linha seja desnecessária
    isTrackingEnabled.value = !isTrackingEnabled.value;
  }
}
