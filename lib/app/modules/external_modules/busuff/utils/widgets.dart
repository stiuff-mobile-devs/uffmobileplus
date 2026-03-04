import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/controller/busuff_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/latLngPoint.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/polyline_points.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

List<Marker> mapMarker(List<LatLngPoint> p) {
  return p
      .map(
        (LatLngPoint e) => Marker(
          point: e.latLng,
          child: CircleAvatar(
            radius: 15,
            child: Text(e.letter, style: TextStyle(fontSize: 12)),
          ),
        ),
      )
      .toList();
}

class BusuffButton extends StatefulWidget {
  final BusuffModel busuffModel;
  const BusuffButton({super.key, required this.busuffModel});

  @override
  State<BusuffButton> createState() => _BusuffButtonState();
}

class _BusuffButtonState extends State<BusuffButton> {
  bool isDialog = false;

  @override
  Widget build(BuildContext context) {
    var d = DateFormat(
      "dd/MM/yyyy hh:mm:ss",
    ).format(widget.busuffModel.timestamp!);
    return GestureDetector(
      child: isDialog
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Text(d),
            )
          : const Icon(Icons.directions_bus),
      onTap: () {
        setState(() {
          isDialog = !isDialog;
        });
      },
    );
  }
}

Marker busuffMarker(BusuffModel busuffModel) {
  return Marker(
    height: 30,
    width: 30,
    point: LatLng(busuffModel.latitude!, busuffModel.longitude!),
    child: Stack(
      children: [
        Container(
          width: 50, // Defina a largura do container
          height: 50, // Defina a altura do container
          decoration: BoxDecoration(
            shape:
                BoxShape.circle, // Define a forma do container como um círculo
            border: Border.all(
              color: Colors.blue, // Cor da borda
              width: 5, // Largura da borda
            ),
            color: Colors.white, // Cor do fundo do container
          ),
          child: Transform.rotate(
            angle: busuffModel.heading == null || busuffModel.speed! <= 3
                ? 0
                : busuffModel.heading! * pi / 180,
            child: Image(
              image: busuffModel.speed != null && busuffModel.speed! <= 3
                  ? const AssetImage("assets/busuff/images/square.png")
                  : const AssetImage("assets/busuff/images/arrow.png"),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget busuffMapWidget(BusuffController c) {
  return Scaffold(
    floatingActionButton: SpeedDial(
      direction: SpeedDialDirection.up,
      backgroundColor: AppColors.darkBlue(),
      foregroundColor: Colors.white,
      activeIcon: Icons.arrow_downward_rounded,
      icon: Icons.arrow_upward_rounded,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.gps_fixed_rounded),
          backgroundColor: AppColors.darkBlue(),
          foregroundColor: Colors.white,
          onTap: () => c.centerOnUser(),
        ),
        if (c.currentMapIndex <= 1 && c.showBusuffButton)
          SpeedDialChild(
            child: const Icon(Icons.directions_bus_rounded),
            backgroundColor: AppColors.darkBlue(),
            foregroundColor: Colors.white,
            onTap: () => c.centerOnBus(),
          ),
      ],
    ),
    body: SlidingUpPanel(
      panel: campusSelectionWidgetMaps(c),
      backdropEnabled: true,
      backdropTapClosesPanel: true,
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      minHeight: 75.0,
      collapsed: Container(
        color: AppColors.darkBlue(),
        child: Center(
          child: Text(
            'Arraste para selecionar a rota',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: FlutterMap(
        mapController: c.mapController,
        options: MapOptions(
          initialCenter:
              c.currentPanning ?? const LatLng(-22.899163, -43.122786),
          initialZoom: 16.5,
          minZoom: 3.0,
          maxZoom: 18.0,
          keepAlive: true,
          interactionOptions: const InteractionOptions(
            flags:
                InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.scrollWheelZoom,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'br.uff.uffmobileplus',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: rota1,
                color: Colors.lightBlue,
                strokeWidth: 4,
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
              Polyline(
                points: rota2,
                color: Colors.lightGreen,
                strokeWidth: 4,
                borderColor: Colors.green,
                borderStrokeWidth: 2,
              ),
              ...createDottedLine(pontilhado, color: Colors.lightGreen),
            ],
          ),
          Obx(() {
            return MarkerLayer(
              markers: [
                // ...mapMarker(c.points[c.currentMapIndex]),
                ...c.busuffs.map(busuffMarker),
                Marker(
                  point: LatLng(c.currentUserLat, c.currentUserLong),
                  child: Icon(Icons.location_pin, color: AppColors.darkBlue()),
                ),
              ],
            );
          }),
        ],
      ),
    ),
  );
}

List<Polyline> createDottedLine(
  List<LatLng> points, {
  Color color = Colors.black,
  double dashLength = 5.0,
}) {
  List<Polyline> dottedLine = [];

  for (int i = 0; i < points.length - 1; i++) {
    LatLng start = points[i];
    LatLng end = points[i + 1];

    // Calcular o número de dashes
    final distance = Distance().as(LengthUnit.Meter, start, end);
    final int dashes = (distance / dashLength).floor();

    // Gerar os pontos para os dashes
    for (int j = 0; j < dashes; j++) {
      double fraction = j / dashes;
      double nextFraction = (j + 1) / dashes;

      LatLng dashStart = LatLng(
        start.latitude + (end.latitude - start.latitude) * fraction,
        start.longitude + (end.longitude - start.longitude) * fraction,
      );
      LatLng dashEnd = LatLng(
        start.latitude + (end.latitude - start.latitude) * nextFraction,
        start.longitude + (end.longitude - start.longitude) * nextFraction,
      );

      dottedLine.add(
        Polyline(points: [dashStart, dashEnd], color: color, strokeWidth: 4.0),
      );
    }
  }

  return dottedLine;
}

Widget busuffStaticWidget(BusuffController c) {
  final imagePath = c.currentImgUrl.trim();

  return SlidingUpPanel(
    panel: campusSelectionWidgetRoutes(c),
    backdropEnabled: true,
    backdropTapClosesPanel: true,
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    minHeight: 75.0,
    collapsed: Container(
      color: AppColors.darkBlue(),
      child: Center(
        child: Text(
          'Arraste para selecionar a rota',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
    body: imagePath.isEmpty
        ? Container(
            color: AppColors.lightBlue(),
            alignment: Alignment.center,
            child: const Text('Sem imagem de rota disponível'),
          )
        : PhotoView(
            imageProvider: AssetImage(
              'assets/busuff/images/rotas_busuff/$imagePath',
            ),
            backgroundDecoration: BoxDecoration(color: AppColors.lightBlue()),
            basePosition: Alignment.topCenter,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.8,
            initialScale: PhotoViewComputedScale.contained,
          ),
    // body: CachedNetworkImage(
    //   imageUrl: c.currentImgUrl,
    //   imageBuilder: (context, imageProvider) => PhotoView(
    //       backgroundDecoration: BoxDecoration(color: AppColors.lightBlue()),
    //       imageProvider: imageProvider,
    //       basePosition: Alignment.topCenter,
    //       minScale: PhotoViewComputedScale.contained * 0.8,
    //       maxScale: PhotoViewComputedScale.covered * 1.8,
    //       initialScale: PhotoViewComputedScale.contained,
    //   ),
    //   placeholder: (context, url) => Container(height: 40,width: 40,child: const CustomProgressDisplay()),
    //   errorWidget: (context, url, error) => Icon(Icons.error),
    // ),
  );
}

Widget campusSelectionWidgetRoutes(BusuffController c) {
  Set s = {6};
  return Column(
    children: [
      SizedBox(height: 80),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: c.routeList.length,
        itemBuilder: (ctx, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: s.contains(index) ? null : () => c.onTapRoutes(true, index),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                color: c.routeList[index].selected
                    ? AppColors.mediumBlue()
                    : AppColors.darkBlue(),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Center(
                child: Text(
                  c.routeList[index].name,
                  style: TextStyle(
                    color: s.contains(index) ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget campusSelectionWidgetMaps(BusuffController c) {
  Set<int> s = Set.from({2, 3, 5});
  return Column(
    children: [
      const SizedBox(height: 80),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: c.routeList.length,
        itemBuilder: (ctx, index) {
          bool b = s.contains(index);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: b ? null : () => c.onTapRoutes(true, index),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: index == c.currentMapIndex
                      ? AppColors.mediumBlue()
                      : AppColors.darkBlue(),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Center(
                  child: Text(
                    c.routeList[index].name,
                    style: TextStyle(color: b ? Colors.grey : Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}
