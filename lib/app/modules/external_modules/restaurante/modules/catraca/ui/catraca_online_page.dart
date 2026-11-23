import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/area_image.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_app_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_status_badge.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class CatracaOnlinePage extends GetView<CatracaController> {
  const CatracaOnlinePage({super.key});

  // Mesmos tons do card de restaurante do cardápio.
  static const Color _cardColor = Color.fromRGBO(13, 19, 33, 1);
  static const Color _ringColor = Color.fromARGB(255, 53, 69, 106);

  @override
  Widget build(BuildContext context) {
    // Sair da catraca com refeições pendentes: avisa que estão seguras e
    // oferece sincronizar antes.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await controller.confirmLeave()) navigator.pop();
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: catracaAppBar(
        title: 'catraca'.tr,
        onRefresh: controller.fetchAreas,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(
          () => controller.isAreaBusy.value
              ? const Center(child: CustomProgressDisplay())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'selecione_o_campus'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const CatracaStatusBadge(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.fetchAreas,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: controller.areas.length,
                          itemBuilder: (context, index) => _AreaCard(
                            area: controller.areas[index],
                            onTap: () => controller.selectArea(index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.area, required this.onTap});

  final AreaModel area;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: CatracaOnlinePage._cardColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _AreaPhoto(path: areaImagePath(area)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    area.nome ?? 'area_sem_nome'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.lightBlue(),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Foto redonda com anel, no estilo do cardápio.
class _AreaPhoto extends StatelessWidget {
  const _AreaPhoto({required this.path});

  final String path;

  static const double _size = 80;

  @override
  Widget build(BuildContext context) {
    final isFallback = path == areaFallbackImage;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFallback ? Colors.white : null,
        border: Border.all(color: CatracaOnlinePage._ringColor, width: 6),
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(isFallback ? 10 : 0),
          child: Image.asset(
            path,
            fit: isFallback ? BoxFit.contain : BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(
              Icons.restaurant_rounded,
              color: AppColors.lightBlue(),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
