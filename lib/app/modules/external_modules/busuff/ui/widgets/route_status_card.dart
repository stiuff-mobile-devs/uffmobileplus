import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/controller/busuff_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/ui/widgets/itinerary_view.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/bus_status.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Cartão fixo sobre o mapa: rota, status do ônibus e acesso ao itinerário.
class RouteStatusCard extends StatelessWidget {
  const RouteStatusCard({super.key, required this.controller});

  final BusuffController controller;

  static const Color _secondaryText = Color(0xFF4A5B70);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: AppColors.darkBlue(alpha: 100),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final route = controller.route;
          final label = controller.routeLabel(route);
          final municipio = controller.municipio.value;
          final status = controller.busStatus;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_bus_rounded,
                      color: AppColors.darkBlue(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$label · ${municipio.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBlue(),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            _StatusDot(live: status != BusStatus.noSignal),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _statusText(status),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (status == BusStatus.noSignal) ...[
                const SizedBox(height: 10),
                Text(
                  'busuff_sem_sinal_msg'.tr,
                  style: const TextStyle(fontSize: 13, color: _secondaryText),
                ),
              ],
              if (route.hasItinerary) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.alternativeMediumBlue(),
                    side: BorderSide(color: AppColors.mediumBlue(), width: 1.5),
                    minimumSize: const Size.fromHeight(44),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => showItinerarySheet(
                    route: route,
                    routeLabel: label,
                    municipioName: municipio.name,
                  ),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text('busuff_ver_itinerario'.tr),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  /// Acima disso a idade da posição ("há 821 dias") parece erro do app para
  /// o aluno e não ajuda em nada; mostra só "Sem sinal".
  static const Duration _maxShownAge = Duration(days: 1);

  String _statusText(BusStatus status) {
    final timestamp = controller.bus?.timestamp;
    final age = timestamp == null
        ? null
        : controller.now.value.difference(timestamp);
    final elapsed = age == null ? '' : formatElapsed(age);
    return switch (status) {
      BusStatus.moving => 'busuff_em_movimento'.trParams({'tempo': elapsed}),
      BusStatus.stopped => 'busuff_parado'.trParams({'tempo': elapsed}),
      BusStatus.noSignal => age == null || age > _maxShownAge
          ? 'busuff_sem_sinal'.tr
          : 'busuff_sem_sinal_desde'.trParams({'tempo': elapsed}),
    };
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.live});

  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: live ? AppColors.mediumBlue() : Colors.transparent,
        border: live
            ? null
            : Border.all(color: const Color(0xFF6B7A8C), width: 2),
      ),
    );
  }
}
