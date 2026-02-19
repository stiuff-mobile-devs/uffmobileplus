import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/monitora_uff_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/permissions_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class MonitoraUFFPage extends StatelessWidget {
  const MonitoraUFFPage({super.key});

  TrackingController get trackingController =>
      Get.find<TrackingController>();
  PermissionsController get permissionsController =>
      Get.find<PermissionsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitora UFF'),
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarBottomGradient()),
        ),
      ),
      body: Obx(
        () => permissionsController.arePermissionsGranted() ? mapa() : permissionScreen(),
      ),
      floatingActionButton: Obx(
        () => permissionsController.arePermissionsGranted()
            ? FloatingActionButton(
                backgroundColor: AppColors.lightBlue(),
                onPressed: trackingController.centerMapOnCurrentLocation,
                child: Icon(Icons.my_location, color: AppColors.darkBlue()),
              )
            : Container(),
      ),
    );
  }

  /// Usuário verá essa tela apenas se todas as permissões necessárias já tiverem
  /// sido concedidas.
  Widget mapa() {
    return FlutterMap(
      mapController: trackingController.mapController,
      options: MapOptions(
        initialCenter: LatLng(
          trackingController.position.latitude,
          trackingController.position.longitude,
        ),
      ),
      children: [tile(), firebaseMarkers(), toggleButton()],
    );
  }

  /// Usuário verá essa tela apenas se algumas das permissões necessárias
  /// ainda não tiver sido concedida.
  Widget permissionScreen() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.appBarBottomGradient()),
      child: Obx(
        () => Align(
          alignment: Alignment.center,
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue(),
                        ),
                        onPressed: permissionsController.requestNotificationPermission,
                        child: const Text("Permitir notificação"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      permissionsController.hasNotificationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue(),
                        ),
                        onPressed: permissionsController.requestWhenInUsePermission,
                        child: const Text("Permitir localização (durante uso)"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      permissionsController.hasWhenInUseLocationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue(),
                        ),
                        onPressed: permissionsController.requestAlwaysPermission,
                        child: const Text("Permitir localização (sempre)"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      permissionsController.hasAlwaysLocationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tile() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'br.uff.sti.uffmobileplus',
    );
  }

  Widget firebaseMarkers() {
    return Obx(
      () => MarkerLayer(
        markers: trackingController.firebaseUsers
            .map(
              (user) => Marker(
                point: LatLng(user.lat, user.lng),
                child: GestureDetector(
                  onTap: () => Get.dialog(popUp(user)),
                  child: Icon(
                    Icons.location_pin,
                    color: trackingController.setMarkerColor(user),
                    size: 50,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget popUp(UserLocationModel user) {
    return AlertDialog(
      title: Text("Usuário"),
      content: Text(user.nome ?? 'Usuário desconhecido'),
    );
  }

  Widget toggleButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: Obx(
        () => FloatingActionButton(
          onPressed: trackingController.toggleService,
          backgroundColor: trackingController.isTrackingEnabled.value
              ? Colors.green
              : Colors.red,
          child: Icon(
            trackingController.isTrackingEnabled.value
                ? Icons.location_on
                : Icons.location_off,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
