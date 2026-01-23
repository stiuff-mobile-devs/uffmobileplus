import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/location_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';

class MonitoraUffController extends GetxController {
  late final MapController mapController;
  late LocationService locationService;
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  final RxList<UserLocationModel> userLocations = <UserLocationModel>[].obs;

  Rx<Position?> get position => locationService.position;

  @override
  void onInit() {
    super.onInit();
    locationService = Get.find<LocationService>();
    locationService.init();
    mapController = MapController();
    fetchUserLocations();
  }

  Future<void> fetchUserLocations() async {
    try {
      final locations = await _firebaseProvider.buscarTodos();
      userLocations.assignAll(locations);
    } catch (e) {
      print("Error fetching user locations: $e");
    }
  }

  void centerMapOnCurrentLocation() {
    if (position != null) {
      mapController.move(LatLng(position.value!.latitude, position.value!.longitude), 15.0);
    }
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }
}
