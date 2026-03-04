import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/route_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/provider/busuff_api.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_alert_dialog.dart';

class BusuffController extends GetxController {
  BusuffController();

  final MapController mapController = MapController();
  final BusuffApiClient busuffApiClient = BusuffApiClient();

  StreamSubscription<Position>? positionStream;
  LatLng? currentPanning;
  Timer? busUffTimer;

  RxBool isLoading = false.obs;
  bool showBusuffButton = false;
  bool permissionGranted = false;
  bool canAskForPermission = false;

  List<BusuffModel> busuffs = [];
  List<RouteModel> routeList = [];

  int currentMapIndex = 0;
  int busuffSelectionIndex = 0;
  int currentRouteIndex = 0;

  String currentImgUrl = '';

  @override
  void onInit() {
    super.onInit();

    routeList = [
      RouteModel('Niterói 1', true, 'niteroi_1.jpeg'),
      RouteModel('Niterói 2', false, 'niteroi_2.jpeg'),
      RouteModel('Campos 1', false, 'campos_1.jpeg'),
      RouteModel('Campos 2', false, 'campos_2.jpeg'),
      RouteModel('Santo Antônio de Pádua', false, 'padua.jpeg'),
      RouteModel('Angra dos Reis', false, 'angra.jpeg'),
      RouteModel('Volta Redonda', false, ''),
    ];

    currentRouteIndex = 0;
    currentImgUrl = routeList.first.routeUrl;
  }

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
    LatLng(-21.5339815355232, -42.18628863683549), // Santo Antônio
    LatLng(-22.898102677293497, -43.11267001291845), // Angra dos Reis
    LatLng(-22.50617992579754, -44.09447740720085), // Volta Redonda
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
    Set<int> s = Set.from({2, 3, 5});
    if (!s.contains(selectedIndex)) {
      currentMapIndex = selectedIndex;
      try {
        mapController.move(positions[selectedIndex], 15.5);
      } catch (e) {
        currentPanning = positions[selectedIndex];
      }
    }
    if (selectedIndex != currentRouteIndex) {
      routeList[selectedIndex].selected = selected; //true
      routeList[currentRouteIndex].selected = false;
      currentImgUrl = routeList[selectedIndex].routeUrl;
      currentRouteIndex = selectedIndex;
      update();
    }
  }

  void goDocBus() {
    Get.toNamed(
      Routes.WEB_VIEW,
      arguments: {
        'url':
            'https://citsmart.uff.br/citsmart/pages/knowledgeBasePortal/knowledgeBasePortal.load#/knowledge/3259',
        'title': 'BusUFF',
      },
    );
  }

  void onTabTap(
    int index,
    TabController tabController,
    BuildContext context,
  ) async {
    //TODO: add the animateTo from controller
    if (index == 1) {
      // tabController!.animateTo(0);
      // await customAlertDialog(
      //   Get.context!,
      //   title: 'Volta Redonda',
      //   desc: 'alert_voltaredonda'.tr,
      //   dismissOnBackKeyPress: false,
      //   dismissOnTouchOutside: true,
      // ).show();
      // return;
      if (!await checkLocationService()) {
        showToastFeedback(context);
        tabController.animateTo(0);
      } else if (!await hasLocationPermission()) {
        await permissionDialog();
        if (canAskForPermission) {
          if (await requestlocationPermissions()) {
            handleLocationInformation();
          } else {
            tabController.animateTo(0);
          }
        } else {
          tabController.animateTo(0);
        }
      } else {
        handleLocationInformation();
      }
    }
  }

  Future<void> handleLocationInformation() async {
    LocationSettings locationSettings = const LocationSettings(
      distanceFilter: 15,
    );
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentUserLat = position.latitude;
    currentUserLong = position.longitude;
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (newPos) {
            currentUserLat = newPos.latitude;
            currentUserLong = newPos.longitude;
          },
        );
    busUffTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await fetchLastKnownBusPosition();
    });
    centerMapOnPosition(currentUserLat, currentUserLong);
  }

  Future<bool> checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled ? true : false;
  }

  void showToastFeedback(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: const Text('Ative o serviço de localização'),
        backgroundColor: AppColors.darkBlue(),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> hasLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      permissionGranted = false;
      // Permissions are denied forever, handle appropriately.
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    permissionGranted = true;
    return true;
  }

  Future<bool> permissionDialog() async {
    await customAlertDialog(
      Get.context!,
      title: 'location'.tr,
      desc: 'location_vr'.tr,
      onConfirm: onConfirm,
      btnCancelText: 'Cancelar',
      onCancel: onCancel,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
    ).show();
    return permissionGranted;
  }

  bool onConfirm() {
    canAskForPermission = true;
    return true;
  }

  bool onCancel() {
    canAskForPermission = false;
    return false;
  }

  Future<bool> requestlocationPermissions() async {
    await Geolocator.requestPermission();
    if (await hasLocationPermission()) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> fetchLastKnownBusPosition() async {
    busuffs = await busuffApiClient.getLastPosition() ?? [];
    update();
  }
}
