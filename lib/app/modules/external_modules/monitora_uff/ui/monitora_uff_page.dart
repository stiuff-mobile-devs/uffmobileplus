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
      body: Stack(
        children: [
          // Área do Mapa (Fundo)
          Obx(() {
             // Centraliza o mapa na localização atual do usuário ou em Niterói se não houver localização
             final center = controller.currentPosition.value ?? LatLng(-22.8966, -43.1238);
             
             return FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
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
                      // Marcadores de outros usuários remotos
                      ...controller.remoteMarkers,
                      // Marcador do próprio usuário
                      if (controller.currentPosition.value != null)
                        Marker(
                          point: controller.currentPosition.value!,
                          width: 80,
                          height: 80,
                          child: GestureDetector(
                            onTap: () {
                              controller.showMarkerInfo(
                                controller.externalModulesServices.getUserName(),
                              );
                            },
                            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ),
                    ],
                  ),
                ],
              );
          }),

          // Controles Flutuantes (Primeiro Plano)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Monitoramento:', 
                          style: TextStyle(
                            color: Colors.black87, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          )
                        ),
                        SizedBox(width: 10),
                        Obx(() => Switch(
                          value: controller.isGathering.value,
                          onChanged: controller.toggleGathering,
                          activeColor: Colors.green,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
