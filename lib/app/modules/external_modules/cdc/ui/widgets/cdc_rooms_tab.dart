import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/services/cdc_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_empty_state.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_room_tile.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Aba Salas: chips de filtro e as seções Obrigatórias, Da CDC e Minhas
/// salas (nessa ordem). Arquivadas só aparecem no filtro delas.
class CdcRoomsTab extends GetView<CdcController> {
  const CdcRoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadRooms,
      child: Obx(() {
        final sections = controller.sections.value;
        final filter = controller.filter.value;

        final List<Widget> children;
        if (controller.isLoading.value && sections.isEmpty) {
          children = [
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: ResponsiveUffLogo(height: 40)),
            ),
          ];
        } else if (controller.loadFailed.value) {
          children = [
            CdcEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'nao_foi_possivel_carregar_salas_chat'.tr,
              message: 'msg_verifique_internet'.tr,
              actionLabel: 'tentar_novamente'.tr,
              onAction: controller.loadRooms,
            ),
          ];
        } else if (sections.isEmpty) {
          children = [
            CdcEmptyState(
              icon: Icons.forum_outlined,
              title: 'nenhuma_sala_disponivel_curso'.tr,
            ),
          ];
        } else {
          children = [
            _FilterChips(sections: sections, selected: filter),
            const SizedBox(height: 8),
            ..._roomList(sections, filter),
          ];
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: children,
        );
      }),
    );
  }

  List<Widget> _roomList(CdcRoomSections sections, CdcRoomFilter filter) {
    if (filter == CdcRoomFilter.archived) {
      return [
        _SectionHeader(
          title: 'cdc_arquivadas'.tr,
          subtitle: 'cdc_arquivadas_subtitulo'.tr,
        ),
        ..._tiles(sections.archived),
      ];
    }

    // Todas: obrigatórias sempre primeiro, depois Da CDC e Minhas salas.
    return [
      if (sections.required.isNotEmpty) ...[
        _SectionHeader(title: 'cdc_obrigatorias'.tr),
        ..._tiles(sections.required),
      ],
      if (sections.cdc.isNotEmpty) ...[
        _SectionHeader(
          title: 'cdc_da_cdc'.tr,
          subtitle: 'cdc_da_cdc_subtitulo'.tr,
        ),
        ..._tiles(sections.cdc),
      ],
      if (sections.mine.isNotEmpty) ...[
        _SectionHeader(title: 'cdc_minhas_salas'.tr),
        ..._tiles(sections.mine),
      ],
      if (sections.of(CdcRoomFilter.all).isEmpty)
        CdcEmptyState(
          icon: Icons.archive_outlined,
          title: 'cdc_todas_arquivadas'.tr,
        ),
    ];
  }

  List<Widget> _tiles(List<CdcChatRoomModel> rooms) => [
        for (final room in rooms)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CdcRoomTile(
              room: room,
              canArchive: controller.canArchive(room),
              onTap: () => controller.openRoom(room),
              onOptions: () => controller.showRoomOptions(room),
            ),
          ),
      ];
}

class _FilterChips extends GetView<CdcController> {
  final CdcRoomSections sections;
  final CdcRoomFilter selected;

  const _FilterChips({required this.sections, required this.selected});

  @override
  Widget build(BuildContext context) {
    final filters = <(CdcRoomFilter, String, int)>[
      (
        CdcRoomFilter.all,
        'cdc_filtro_todas'.tr,
        sections.of(CdcRoomFilter.all).length,
      ),
      (CdcRoomFilter.archived, 'cdc_arquivadas'.tr, sections.archived.length),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (value, label, count) in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$label  $count'),
                selected: value == selected,
                showCheckmark: false,
                onSelected: (_) => controller.selectFilter(value),
                labelStyle: TextStyle(
                  color: value == selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                selectedColor: AppColors.mediumBlue(),
                side: BorderSide(
                  color: value == selected
                      ? AppColors.mediumBlue()
                      : Colors.white.withValues(alpha: 0.15),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.lightBlue(),
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
