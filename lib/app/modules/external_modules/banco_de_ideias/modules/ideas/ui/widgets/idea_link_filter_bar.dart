import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'idea_link_filter.dart';

class IdeaLinkFilterBar extends GetView<BancoDeIdeiasController> {
  const IdeaLinkFilterBar({
    super.key,
    required this.selectedFilters,
    required this.onToggle,
  });

  final Set<IdeaLinkFilter> selectedFilters;
  final ValueChanged<IdeaLinkFilter> onToggle;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFFD9E2EC)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final filtro in IdeaLinkFilter.values)
            FilterChip(
              selected: selectedFilters.contains(filtro),
              avatar: Icon(filtro.icon, size: 18),
              label: Text(filtro.label),
              onSelected: (_) => onToggle(filtro),
            ),
        ],
      ),
    ),
  );
}
