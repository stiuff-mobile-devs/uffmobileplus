import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/route_model.dart';

class BusuffController extends GetxController {
  BusuffController();

  final MapController mapController = MapController();
    LatLng? currentPanning;

  RxBool isLoading = false.obs;
  bool showBusuffButton = false;

  List<BusuffModel> busuffs = [];
    List<RouteModel> routeList = [];

  int currentMapIndex = 0;
  int busuffSelectionIndex = 0;
    int currentRouteIndex = 0;

   String currentImgUrl = '';


  // Latitude do user - instantaneo
  final RxDouble _currentUserLat = 0.0.obs;
  double get currentUserLat => _currentUserLat.value;
  set currentUserLat(value) => _currentUserLat.value = value;

  // Longitude do user - instantaneo
  final RxDouble _currentUserLong = 0.0.obs;
  double get currentUserLong => _currentUserLong.value;
  set currentUserLong(value) => _currentUserLong.value = value;

  final List<LatLng> positions = [
    LatLng(-22.901861605776794, -43.12946240402702), // Niteroi 1
    LatLng(-22.898102677293497, -43.11267001291845), // Niteroi 2

    LatLng(-22.898102677293497, -43.11267001291845), // Campos 1
    LatLng(-22.898102677293497, -43.11267001291845), // Campos 2
    LatLng(-21.5339815355232, -42.18628863683549),   // Santo Antônio
    LatLng(-22.898102677293497, -43.11267001291845), // Angra dos Reis
    LatLng(-22.50617992579754, -44.09447740720085) // Volta Redonda
  ];

  void centerOnUser() {
    centerMapOnPosition(currentUserLat, currentUserLong);
  }

  void centerOnBus() {
    if (busuffs.isEmpty) {
      return;
    }
    var bus = busuffs[busuffSelectionIndex];
    centerMapOnPosition(bus.latitude!, bus.longitude!);
    busuffSelectionIndex = (busuffSelectionIndex + 1) % busuffs.length;
  }

  void centerMapOnPosition(double lat, double long) {
    mapController.move(LatLng(lat, long), mapController.camera.zoom);
  }

  void onTapRoutes(bool selected, int selectedIndex) {
    //TODO: save the city on storage
    Set<int> s = Set.from({2,3,5});
    if (!s.contains(selectedIndex)) {
      currentMapIndex = selectedIndex;
      try {
        mapController.move(positions[selectedIndex], 15.5);
      } catch (e) {
        currentPanning = positions[selectedIndex];
      }
    }
    if(selectedIndex != currentRouteIndex){
      routeList[selectedIndex].selected = selected;//true
      routeList[currentRouteIndex].selected = false;
      currentImgUrl = routeList[selectedIndex].routeUrl;
      currentRouteIndex = selectedIndex;
      update();
    }
  }
}
