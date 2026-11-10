import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Barra flutuante Home/Serviços da dashboard.
///
/// Substitui o `persistent_bottom_nav_bar`, que ignorava a área segura quando a
/// barra tinha margem inferior: em aparelhos com botões/gestos ou no iPhone a
/// pílula ficava atrás da área do sistema. Aqui o [SafeArea] garante o espaço,
/// e a altura cresce com a fonte do sistema em vez de estourar.
class DashboardNavBar extends GetView<DashboardController> {
  const DashboardNavBar({super.key});

  static const Color _barColor = Color(0xFF0A1C34);
  static const Color _activeBackground = Color(0xFF0B1424);
  static const Color _inactiveColor = Color(0xFFC9D3E4);

  @override
  Widget build(BuildContext context) {
    // Limita o aumento da fonte só aqui: com a fonte no máximo a barra ainda
    // cresce, mas sem ocupar metade da tela.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _barColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Obx(() {
              final current = controller.currentIndex.value;
              return Row(
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'home_page'.tr,
                    selected: current == DashboardController.homeTab,
                    onTap: () =>
                        controller.goToTab(DashboardController.homeTab),
                  ),
                  _NavItem(
                    icon: Icons.apps_rounded,
                    label: 'servicos'.tr,
                    selected: current == DashboardController.servicesTab,
                    onTap: () =>
                        controller.goToTab(DashboardController.servicesTab),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.lightBlue() : DashboardNavBar._inactiveColor;

    return Expanded(
      flex: selected ? 2 : 1,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? DashboardNavBar._activeBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
