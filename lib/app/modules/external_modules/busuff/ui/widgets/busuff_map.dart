
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/controller/busuff_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/bus_status.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Mapa com só a rota selecionada, o ônibus dela e a posição do usuário.
class BusuffMap extends StatelessWidget {
  const BusuffMap({super.key, required this.controller});

  final BusuffController controller;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: controller.municipio.value.center,
        initialZoom: 15,
        minZoom: 3,
        maxZoom: 18,
        onMapReady: controller.onMapReady,
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.scrollWheelZoom |
              InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.uff.uffmobileplus',
        ),
        Obx(() {
          final route = controller.route;
          return PolylineLayer(
            polylines: [
              if (route.polyline.isNotEmpty)
                Polyline(
                  points: route.polyline,
                  color: AppColors.mediumBlue(),
                  strokeWidth: 5,
                  borderColor: AppColors.darkBlue(),
                  borderStrokeWidth: 2,
                ),
              if (route.dashedPolyline.isNotEmpty)
                Polyline(
                  points: route.dashedPolyline,
                  color: AppColors.mediumBlue(),
                  strokeWidth: 4,
                  pattern: StrokePattern.dashed(segments: [8, 6]),
                ),
            ],
          );
        }),
        Obx(() {
          final bus = controller.bus;
          final user = controller.userPosition.value;
          final status = controller.busStatus;
          return MarkerLayer(
            markers: [
              if (user != null)
                Marker(point: user, width: 44, height: 44, child: _userDot()),
              if (bus != null && status != BusStatus.noSignal)
                Marker(
                  point: LatLng(bus.latitude!, bus.longitude!),
                  width: 64,
                  height: 80,
                  alignment: Alignment.center,
                  child: _BusMarker(
                    bus: bus,
                    label: controller.routeLabel(controller.route),
                    moving: status == BusStatus.moving,
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _userDot() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mediumBlue(alpha: 46),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkBlue(),
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}

/// Crédito exigido pela licença dos tiles do OpenStreetMap. Fica no overlay
/// da página, e não dentro do mapa, para não ser coberto pelo cartão da rota.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  static final Uri _copyrightUrl =
      Uri.https('www.openstreetmap.org', '/copyright');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () =>
            launchUrl(_copyrightUrl, mode: LaunchMode.externalApplication),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '© OpenStreetMap',
            style: TextStyle(fontSize: 11, color: AppColors.darkBlue()),
          ),
        ),
      ),
    );
  }
}

class _BusMarker extends StatelessWidget {
  const _BusMarker({
    required this.bus,
    required this.label,
    required this.moving,
  });

  final BusuffModel bus;
  final String label;
  final bool moving;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.darkBlue(),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.mediumBlue(), width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
          child: moving
              ? Transform.rotate(
                  angle: (bus.heading ?? 0) * pi / 180,
                  child: Icon(
                    Icons.navigation_rounded,
                    size: 18,
                    color: AppColors.darkBlue(),
                  ),
                )
              : Icon(
                  Icons.directions_bus_rounded,
                  size: 18,
                  color: AppColors.darkBlue(),
                ),
        ),
      ],
    );
  }
}
