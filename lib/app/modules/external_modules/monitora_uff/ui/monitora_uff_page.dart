import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:latlong2/latlong.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/monitora_uff_controller.dart';
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
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            // posição do dispositivo se possível ou coordenadas de Niteró c.c.
            controller.position.value?.latitude ?? -22.8807,
            controller.position.value?.longitude ?? -43.1014
          )
        ),
        children: [
          mapa(),
          firebaseMarkers(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.centerMapOnCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget mapa() {
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
                child: Icon(Icons.location_pin, color: Colors.red, size: 50),
              ),
            )
            .toList(),
      ),
    );
  }
}
