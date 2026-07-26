import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/home/ui/widgets/new_idea_button.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/home/ui/widgets/user_destination.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/home/ui/widgets/user_home_content.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/ui/pages/admin_table_selection_page.dart';

class BancoDeIdeiasHomePage extends GetView<BancoDeIdeiasController> {
  const BancoDeIdeiasHomePage({super.key});

  static const routeName = '/banco-de-ideias';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BancoDeIdeiasController>(
      builder: (controller) {
        final destination = controller.selectedDestination;
        final isMobile = MediaQuery.sizeOf(context).width < 700;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Banco de Ideias'),
            centerTitle: true,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppColors.appBarTopGradient(),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColors.darkBlueToBlackGradient(),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMobile)
                    _DesktopNavigation(
                      selectedIndex: controller.selectedIndex,
                      destinations: BancoDeIdeiasController.destinations,
                      onDestinationSelected: controller.selectDestination,
                    ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Padding(
                          padding: isMobile
                              ? const EdgeInsets.fromLTRB(16, 18, 16, 20)
                              : const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: UserHomeContent(
                            destination: destination,
                            ideiaApiService: controller.ideiaApiService,
                            usuarioApiService: controller.usuarioApiService,
                            refreshToken: controller.refreshToken,
                            onOpenAdminPanel: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminTableSelectionPage(),
                              ),
                            ),
                            onSignOut: controller.signOut,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: isMobile
              ? _MobileBottomActions(
                  selectedIndex: controller.selectedIndex,
                  destinations: BancoDeIdeiasController.destinations,
                  onDestinationSelected: controller.selectDestination,
                )
              : null,
          floatingActionButton: controller.mostrarBotaoNovaIdeia
              ? NewIdeaButton(
                  ideiaApiService: controller.ideiaApiService,
                  onIdeaCreated: controller.recarregarIdeias,
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}

class _DesktopNavigation extends GetView<BancoDeIdeiasController> {
  const _DesktopNavigation({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<UserDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRailTheme(
      data: NavigationRailThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        indicatorColor: AppColors.lightBlue(alpha: 54),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        unselectedIconTheme: const IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        minWidth: 92,
        leading: const SizedBox(height: 12),
        destinations: [
          for (final item in destinations)
            NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            ),
        ],
      ),
    );
  }
}

class _MobileBottomActions extends GetView<BancoDeIdeiasController> {
  const _MobileBottomActions({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<UserDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkBlue(),
      elevation: 3,
      child: SafeArea(
        top: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.darkBlue(),
            indicatorColor: AppColors.lightBlue(alpha: 54),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected ? Colors.white : Colors.white70,
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              for (final item in destinations)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
