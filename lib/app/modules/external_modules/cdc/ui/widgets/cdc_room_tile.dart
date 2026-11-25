import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Uma sala na lista. Toque abre a sala; obrigatórias mostram o cadeado e
/// não têm menu (não podem ser arquivadas).
class CdcRoomTile extends StatelessWidget {
  final CdcChatRoomModel room;
  final bool canArchive;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  const CdcRoomTile({
    super.key,
    required this.room,
    required this.canArchive,
    required this.onTap,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final accent = room.isRequired ? Colors.amber.shade300 : AppColors.lightBlue();

    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: canArchive ? onOptions : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: room.isRequired
                  ? Colors.amber.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_badges.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(spacing: 6, runSpacing: 4, children: _badges),
                    ],
                  ],
                ),
              ),
              if (canArchive)
                IconButton(
                  tooltip: 'cdc_opcoes_sala'.tr,
                  icon: const Icon(Icons.more_vert_rounded),
                  color: Colors.white70,
                  onPressed: onOptions,
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    if (room.isRequired) return Icons.lock_outline_rounded;
    if (room.type.toLowerCase() == 'report') {
      return Icons.report_gmailerrorred_rounded;
    }
    return Icons.chat_bubble_outline_rounded;
  }

  /// Uma etiqueta principal por sala (Obrigatória, Oficial ou Google Chat) e,
  /// na oficial em que o aluno já está no Chat, "Você participa".
  List<Widget> get _badges => [
        switch (room.category) {
          CdcRoomCategory.required => _Badge(
              label: 'cdc_selo_obrigatoria'.tr,
              color: Colors.amber.shade300,
            ),
          CdcRoomCategory.cdc => _Badge(
              label: 'cdc_selo_oficial'.tr,
              color: AppColors.lightBlue(),
            ),
          CdcRoomCategory.mine => _Badge(
              label: 'cdc_selo_google_chat'.tr,
              color: Colors.white70,
            ),
        },
        if (room.isMember)
          _Badge(
            label: 'cdc_selo_voce_participa'.tr,
            color: Colors.greenAccent.shade200,
          ),
      ];
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
