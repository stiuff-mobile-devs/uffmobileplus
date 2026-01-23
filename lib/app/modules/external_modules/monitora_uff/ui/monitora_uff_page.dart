import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/monitora_uff_controller.dart';

class MonitoraUFFPage extends GetView<MonitoraUffController> {
  const MonitoraUFFPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitora UFF'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
        // Se não possui posição ainda => indica carregamento
        // Senão mostra o mapa
        () => controller.position.value == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Obtendo localização...'),
                  ],
                ),
              )
            : FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    controller.position.value!.latitude,
                    controller.position.value!.longitude,
                  ),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.autoagent',
                  ),
                  MarkerLayer(
                    markers: [
                      // Marcador da posição atual
                      if (controller.position.value != null)
                        Marker(
                          point: LatLng(
                            controller.position.value!.latitude,
                            controller.position.value!.longitude,
                          ),
                          width: 80,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Marcadores dos usuários buscados
                      ...controller.userLocations
                          .where((u) => u.lat != null && u.long != null)
                          .map(
                            (u) => Marker(
                              point: LatLng(u.lat!, u.long!),
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                    ],
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.centerMapOnCurrentLocation,
        tooltip: 'Centralize no meu local',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
