import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/route_model.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

const String _itineraryFolder = 'assets/busuff/images/rotas_busuff/';

/// Abre o itinerário da rota em folha, com zoom por pinça.
Future<void> showItinerarySheet({
  required RouteModel route,
  required String routeLabel,
  required String municipioName,
}) {
  return AppPopups.custom(
    Builder(
      builder: (ctx) => AppSheet(
        title: 'busuff_itinerario_de'.trParams({'rota': routeLabel}),
        message: '$municipioName · ${'busuff_pince_ampliar'.tr}',
        maxHeightFactor: 0.92,
        actions: [
          AppSheetButton.secondary(
            label: 'fechar'.tr,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.55,
            child: _ZoomableItinerary(route: route),
          ),
        ),
      ),
    ),
  );
}

class _ZoomableItinerary extends StatelessWidget {
  const _ZoomableItinerary({required this.route});

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: AssetImage('$_itineraryFolder${route.itineraryImage}'),
      backgroundDecoration: const BoxDecoration(color: Colors.white),
      basePosition: Alignment.topCenter,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2.5,
      initialScale: PhotoViewComputedScale.contained,
    );
  }
}

/// Corpo da tela para municípios sem rastreio: aviso + itinerário, ou um
/// estado vazio quando nem a imagem existe.
class ItineraryView extends StatelessWidget {
  const ItineraryView({
    super.key,
    required this.route,
    required this.routeLabel,
    required this.municipioName,
  });

  final RouteModel route;
  final String routeLabel;
  final String municipioName;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.lightBlue(),
      child: Center(
        child: ConstrainedBox(
          // Em telas largas o itinerário não estica até as bordas.
          constraints: const BoxConstraints(maxWidth: 720),
          child: route.hasItinerary ? _withImage() : _empty(),
        ),
      ),
    );
  }

  Widget _withImage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Banner(
            title: 'busuff_sem_rastreio_titulo'.tr,
            message: 'busuff_sem_rastreio_msg'.tr,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _ZoomableItinerary(route: route)),
                  const Divider(height: 1),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.alternativeMediumBlue(),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => showItinerarySheet(
                      route: route,
                      routeLabel: routeLabel,
                      municipioName: municipioName,
                    ),
                    icon: const Icon(Icons.open_in_full_rounded, size: 18),
                    label: Text('busuff_ampliar_itinerario'.tr),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.map_outlined,
              size: 34,
              color: AppColors.alternativeMediumBlue(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'busuff_sem_itinerario_titulo'.trParams({'municipio': municipioName}),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'busuff_sem_itinerario_msg'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF3E4F64)),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.mediumBlue()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBlue(),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A5B70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
