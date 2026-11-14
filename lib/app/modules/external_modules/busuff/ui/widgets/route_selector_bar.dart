import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/controller/busuff_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Parte de baixo da AppBar: botão do município + chips das rotas.
class RouteSelectorBar extends StatelessWidget implements PreferredSizeWidget {
  const RouteSelectorBar({super.key, required this.controller});

  final BusuffController controller;

  /// Até este número de rotas os chips dividem a largura; acima, rolam.
  static const int _maxSegments = 3;
  static const double _height = 44;

  @override
  Size get preferredSize => const Size.fromHeight(_height + 14);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: LayoutBuilder(
        builder: (context, constraints) => Obx(() {
          final municipio = controller.municipio.value;
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.45,
                ),
                child: _MunicipioButton(
                  name: municipio.name,
                  onPressed: controller.chooseMunicipio,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _routeChips()),
            ],
          );
        }),
      ),
    );
  }

  Widget _routeChips() {
    final routes = controller.municipio.value.routes;
    final selected = controller.routeIndex.value;
    final chips = [
      for (int i = 0; i < routes.length; i++)
        _RouteChip(
          label: controller.routeLabel(routes[i]),
          selected: i == selected,
          onTap: routes.length > 1 ? () => controller.selectRoute(i) : null,
        ),
    ];

    return Container(
      height: _height,
      padding: const EdgeInsets.all(3),
      decoration: _outlinedPill,
      child: routes.length <= _maxSegments
          ? Row(
              children: [
                for (int i = 0; i < chips.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(child: chips[i]),
                ],
              ],
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 3),
              itemBuilder: (_, i) => SizedBox(width: 88, child: chips[i]),
            ),
    );
  }
}

final BoxDecoration _outlinedPill = BoxDecoration(
  color: Colors.white.withValues(alpha: 0.12),
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
);

class _MunicipioButton extends StatelessWidget {
  const _MunicipioButton({required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'busuff_trocar_municipio'.trParams({'municipio': name}),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Ink(
            height: RouteSelectorBar._height,
            padding: const EdgeInsets.only(left: 12, right: 8),
            decoration: _outlinedPill,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  const _RouteChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        elevation: selected ? 1 : 0,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppColors.darkBlue() : Colors.white,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
