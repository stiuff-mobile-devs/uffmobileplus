import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/data/services/external_gdi_service.dart';
import '../data/models/campus_model.dart';
import '../data/repository/restaurant_repository.dart';

class RestaurantsController extends GetxController {
  RestaurantsController();

  RestaurantRepository restaurantRepository = Get.put(RestaurantRepository());
  ExternalGDIService gdiService = Get.find<ExternalGDIService>();

  final evenDarkerBlue = const Color.fromRGBO(13, 19, 33, 1);
  final darkBlue = const Color.fromRGBO(26, 38, 64, 1.0);
  final mediumDarkBlue = const Color.fromARGB(255, 53, 69, 106);
  final rareDarkBlue = const Color.fromARGB(255, 38, 54, 90);

  bool isLoading = true;
  List<Campus> locations = [];

  int isFetchLoading = 1;

  /// 0 - Common Access
  /// 1 - Admin
  int debugMode = 0;
  bool isDebugActive = false;

  get stats => null;

  bool? isAdminModeEnabled() {
    // return gdiProvider
    //             .isInGroup(GdiGroups.adminCardapioRestauranteUniversitario) &&
    //         !isDebugActive ||
    //     (isDebugActive && debugMode == 1);
  }

  @override
  void onInit() {
    _initializeLocations();
    Future.delayed(const Duration(seconds: 1), () {
      isLoading = false;
      update();
    });
    super.onInit();
  }

  void _initializeLocations() {
    Campus gr = Campus(
      name: 'Gragoatá',
      address: 'R. Prof. Marcos Waldemar de Freitas Reis',
      latitude: -22.89874728234421,
      longitude: -43.13222613102928,
      colorId: LocationColor.orange,
      iconImgPath: 'assets/restaurant/img/gr.png',
      panelImgPath: 'assets/restaurant/img/gr-banner.png',
    );

    Campus pv = Campus(
      name: 'Praia Vermelha',
      address: 'R. Passo da Pátria, 152-470',
      latitude: -22.90532486896256,
      longitude: -43.13205992739933,
      colorId: LocationColor.green,
      iconImgPath: 'assets/restaurant/img/pv.png',
      panelImgPath: 'assets/restaurant/img/pv-banner.png',
    );

    Campus re = Campus(
      name: 'Reitoria',
      address: 'R. Miguel de Frias, 9',
      latitude: -22.903100458336205,
      longitude: -43.11663976801507,
      colorId: LocationColor.red,
      iconImgPath: 'assets/restaurant/img/re.png',
      panelImgPath: 'assets/restaurant/img/re-banner.png',
    );

    Campus ve = Campus(
      name: 'Veterinária',
      address: 'Av. Alm. Ary Parreiras, 507',
      latitude: -22.90557897632478,
      longitude: -43.09826157388613,
      colorId: LocationColor.blue,
      iconImgPath: 'assets/restaurant/img/ve.png',
      panelImgPath: 'assets/restaurant/img/ve-banner.png',
    );

    Campus hu = Campus(
      name: 'HUAP',
      address: 'Av. Marquês do Paraná, 303',
      latitude: -22.895181826741158,
      longitude: -43.11204116153949,
      colorId: LocationColor.purple,
      iconImgPath: 'assets/restaurant/img/hu.png',
      panelImgPath: 'assets/restaurant/img/hu-banner.png',
    );

    locations = [gr, pv, re, ve, hu];
    update();
  }

  Future<T?> fetchWithRetries<T>(
      BuildContext context, Future<T?> Function() fetchFunction,
      {int retries = 5,
      int delayMilliseconds = 100,
      bool showTimeout = true}) async {
    isFetchLoading = 1;
    for (int i = 0; i < retries; i++) {
      final result = await fetchFunction();
      if (result != null) {
        isFetchLoading = 0;
        return result;
      }
      if (i == 4 && result == null) {
        // isFetchLoading = -1;
        if (showTimeout) {
          Get.snackbar(
            'Erro: Timeout',
            'A operação atingiu o tempo limite. Por favor, recarregue a página.',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("Fetch retrying!");
        await Future.delayed(Duration(milliseconds: delayMilliseconds));
      }
    }
    return null;
  }
}
