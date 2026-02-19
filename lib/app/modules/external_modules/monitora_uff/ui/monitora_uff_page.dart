import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:latlong2/latlong.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/monitora_uff_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class MonitoraUFFPage extends GetView<MonitoraUffController> {
  const MonitoraUFFPage({super.key});
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
      body: Obx(() => controller.arePermissionsGranted() 
        ? mapa() 
        : permissionScreen()),
      floatingActionButton: Obx(() => controller.arePermissionsGranted()
          ? FloatingActionButton(
            backgroundColor: AppColors.lightBlue(),
            onPressed: controller.centerMapOnCurrentLocation,
            child: Icon(Icons.my_location, color: AppColors.darkBlue()),
        )
          : Container()),
    );
  }

  /// Usuário verá essa tela apenas se todas as permissões necessárias já tiverem
  /// sido concedidas.
  Widget mapa() {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: LatLng(
          controller.position.latitude,
          controller.position.longitude,
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
                          onPressed: controller.requestNotificationPermission,
                          child: const Text("Permitir notificação")),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      controller.hasNotificationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    )
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
                          onPressed: controller.requestWhenInUsePermission,
                          child:
                              const Text("Permitir localização (durante uso)")),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      controller.hasWhenInUseLocationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    )
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
                          onPressed: controller.requestAlwaysPermission,
                          child: const Text("Permitir localização (sempre)")),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      controller.hasAlwaysLocationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    )
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
        markers: controller.firebaseUsers
            .map(
              (user) => Marker(
                point: LatLng(user.lat, user.lng),
                child: GestureDetector(
                  onTap: () => Get.dialog(popUp(user)),
                  child: Icon(
                    Icons.location_pin,
                    color: controller.setMarkerColor(user),
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
          onPressed: () {
            controller.toggleService();
          },
          backgroundColor: controller.isTrackingEnabled.value
              ? Colors.green
              : Colors.red,
          child: Icon(
            controller.isTrackingEnabled.value
                ? Icons.location_on
                : Icons.location_off,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
