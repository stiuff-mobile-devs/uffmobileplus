import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/monitora_uff_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class MonitoraUffPage extends GetView<MonitoraUffController> {
  const MonitoraUffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text("Monitora UFF"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Column(
          children: [
            // Custom App Bar / Header area
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: AppColors.appBarTopGradient(),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                  ]
              ),
              child: Column(
                children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Monitoramento:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        SizedBox(width: 10),
                        Obx(() => Switch(
                          value: controller.isGathering.value,
                          onChanged: controller.toggleGathering,
                          activeColor: AppColors.lightBlue(),
                        )),
                      ],
                    ),
                    Obx(() => Text(
                      controller.coordinates.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )),
                ],
              ),
            ),
            
            // Map Area
            Expanded(
              child: Obx(() {
                 // Determine center: if we have a position, use it. Else, default to Niterói/UFF.
                 // We only move map if mapController.move is called, or we update options? 
                 // Updating options usually doesn't move map after init.
                 // We can use the MapController in the controller logic, but for init we need a value.
                 // Niterói coordinates: -22.896620, -43.123793 (approx)
                  final center = controller.currentPosition.value ?? LatLng(-22.8966, -43.1238); 
                return FlutterMap(
                    mapController: controller.mapController,
                    options: MapOptions(
                      // If we have a position, use it as initial center. 
                      // Note: changing initialCenter after build doesn't move map, we use controller.move for updates.
                      initialCenter: center, 
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'br.uff.uffmobileplus',
                      ),
                        MarkerLayer(
                          markers: [
                            ...controller.remoteMarkers,
                            if (controller.currentPosition.value != null)
                              Marker(
                                point: controller.currentPosition.value!,
                                width: 80,
                                height: 80,
                                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                              ),
                          ],
                        ),
                    ],
                  );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
