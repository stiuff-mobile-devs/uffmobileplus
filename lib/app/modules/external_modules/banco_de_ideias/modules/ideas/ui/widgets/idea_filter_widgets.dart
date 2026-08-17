import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/data/idea_filter_models.dart';

class IdeaFilterSearchRow extends GetView<BancoDeIdeiasController> {
  const IdeaFilterSearchRow({
    super.key,
    required this.textController,
    required this.canOpenFilters,
    required this.hasFiltro,
    required this.onSearch,
    required this.onOpenFilters,
    required this.onClear,
  });

  final TextEditingController textController;
  final bool canOpenFilters;
  final bool hasFiltro;
  final VoidCallback onSearch;
  final VoidCallback? onOpenFilters;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final searchField = Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIconColor: Colors.white70,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.lightBlue()),
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.lightBlue(),
            ),
          ),
          child: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: const InputDecoration(
              labelText: 'Pesquisar por titulo',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: compact ? WrapAlignment.end : WrapAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: onSearch,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mediumBlue(),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Buscar'),
            ),
            OutlinedButton.icon(
              onPressed: canOpenFilters ? onOpenFilters : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
              ),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Filtros'),
            ),
            if (hasFiltro)
              IconButton.filledTonal(
                tooltip: 'Limpar filtros',
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 10),
            actions,
          ],
        );
      },
    );
  }
}

class IdeaActiveFilterChips extends GetView<BancoDeIdeiasController> {
  const IdeaActiveFilterChips({
    super.key,
    required this.filters,
    required this.onRemove,
  });

  final List<IdeaActiveFilter> filters;
  final ValueChanged<IdeaActiveFilter> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in filters)
          InputChip(
            avatar: const Icon(Icons.filter_alt_rounded, size: 18),
            label: Text('${filter.label}: ${filter.value}'),
            backgroundColor: Colors.white.withValues(alpha: 0.10),
            labelStyle: const TextStyle(color: Colors.white),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            deleteIconColor: Colors.white70,
            tooltip: 'Remover filtro ${filter.label.toLowerCase()}',
            onPressed: () => onRemove(filter),
            onDeleted: () => onRemove(filter),
          ),
      ],
    );
  }
}
