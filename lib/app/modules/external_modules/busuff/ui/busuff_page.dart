import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/controller/busuff_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/ui/widgets/busuff_map.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/ui/widgets/itinerary_view.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/ui/widgets/route_selector_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/ui/widgets/route_status_card.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/busuff_help.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';

class BusuffPage extends GetView<BusuffController> {
  const BusuffPage({super.key});

  /// Acima desta largura o cartão da rota deixa de ocupar a tela toda.
  static const double _wideLayoutMinWidth = 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(
        title: 'BusUFF'.tr,
        actions: [AppBars.helpAction(BusuffHelp.pagina)],
        bottom: RouteSelectorBar(controller: controller),
      ),
      body: Obx(() {
        final municipio = controller.municipio.value;
        if (!municipio.isTracked) {
          return ItineraryView(
            route: controller.route,
            routeLabel: controller.routeLabel(controller.route),
            municipioName: municipio.name,
          );
        }
        return Stack(
          children: [
            Positioned.fill(child: BusuffMap(controller: controller)),
            Positioned.fill(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        constraints.maxWidth > _wideLayoutMinWidth
                            ? _wideOverlay()
                            : _narrowOverlay(),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Celular: atribuição e botões acima do cartão, que ocupa a largura toda.
  Widget _narrowOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const MapAttribution(),
            const Spacer(),
            _mapButtons(),
          ],
        ),
        const SizedBox(height: 12),
        RouteStatusCard(controller: controller),
      ],
    );
  }

  /// Tablet/janela larga: cartão à esquerda com largura limitada, botões à
  /// direita, sem sobreposição.
  Widget _wideOverlay() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MapAttribution(),
              const SizedBox(height: 8),
              RouteStatusCard(controller: controller),
            ],
          ),
        ),
        const Spacer(),
        _mapButtons(),
      ],
    );
  }

  Widget _mapButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'busuff_centralizar_onibus',
          tooltip: 'busuff_centralizar_onibus'.tr,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkBlue(),
          shape: const CircleBorder(),
          onPressed: controller.centerOnBus,
          child: const Icon(Icons.directions_bus_rounded),
        ),
        const SizedBox(height: 12),
        Obx(
          () => FloatingActionButton(
            heroTag: 'busuff_minha_localizacao',
            tooltip: 'busuff_minha_localizacao'.tr,
            backgroundColor: AppColors.darkBlue(),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: controller.centerOnUser,
            child: Icon(
              controller.userPosition.value == null
                  ? Icons.location_searching_rounded
                  : Icons.my_location_rounded,
            ),
          ),
        ),
      ],
    );
  }
}
