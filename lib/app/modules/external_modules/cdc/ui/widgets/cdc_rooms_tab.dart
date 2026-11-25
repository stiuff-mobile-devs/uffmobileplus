import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/services/cdc_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_empty_state.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_google_chat_card.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_room_tile.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Aba Salas: filtros Todas/Arquivadas e uma lista única, com as
/// obrigatórias primeiro. Arquivadas só aparecem no filtro delas.
class CdcRoomsTab extends GetView<CdcController> {
  const CdcRoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshAll,
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
              onAction: controller.refreshAll,
            ),
          ];
        } else if (sections.isEmpty) {
          children = [
            const CdcGoogleChatCard(),
            CdcEmptyState(
              icon: Icons.forum_outlined,
              title: 'nenhuma_sala_disponivel_curso'.tr,
            ),
          ];
        } else {
          children = [
            const CdcGoogleChatCard(),
            _FilterChips(sections: sections, selected: filter),
            const SizedBox(height: 8),
            ..._roomList(sections, filter),
            _UpdatedAt(date: controller.updatedAt.value),
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

    // Todas: lista única, com as obrigatórias sempre primeiro.
    if (sections.active.isEmpty) {
      return [
        CdcEmptyState(
          icon: Icons.archive_outlined,
          title: 'cdc_todas_arquivadas'.tr,
        ),
      ];
    }
    return _tiles(sections.active);
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

    return Row(
      children: [
        for (final (value, label, count) in filters)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterPill(
              label: '$label  $count',
              selected: value == selected,
              onTap: () => controller.selectFilter(value),
            ),
          ),
      ],
    );
  }
}

/// Pílula de filtro com cores próprias (o ChoiceChip do Material 3 ignora o
/// fundo passado e deixava o não selecionado branco com texto branco).
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: selected
            ? AppColors.mediumBlue()
            : Colors.white.withValues(alpha: 0.15),
      ),
    );
    return Material(
      color: selected
          ? AppColors.mediumBlue()
          : Colors.white.withValues(alpha: 0.08),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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

/// "Atualizado em dd/MM às HH:mm": a lista é a guardada no aparelho.
class _UpdatedAt extends StatelessWidget {
  final DateTime? date;
  const _UpdatedAt({required this.date});

  @override
  Widget build(BuildContext context) {
    final d = date;
    if (d == null) return const SizedBox.shrink();
    final local = d.toLocal();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        'cdc_atualizado_em'.trParams({
          'data': DateFormat('dd/MM').format(local),
          'hora': DateFormat('HH:mm').format(local),
        }),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }
}
