import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/external_modules_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/home_page.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class Dashboard extends GetView<DashboardController> {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: controller.tabController,
        screens: const [HomePage(), ExternalModulesPage()],
        backgroundColor: const Color(0xFF0A1C34),
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(18),
          colorBehindNavBar: const Color(0xFF060D19),
        ),
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        items: [
          // Tela Principal
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.dashboard_rounded),
            title: 'Home Page'.tr,
            activeColorPrimary: const Color(0xFF0B1424),
            inactiveColorPrimary: const Color(0xFFC9D3E4),
            activeColorSecondary: AppColors.lightBlue(),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),

          // Tela de Serviços
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.apps_rounded),
            title: 'Módulos'.tr,
            activeColorPrimary: const Color(0xFF0B1424),
            inactiveColorPrimary: const Color(0xFFC9D3E4),
            activeColorSecondary: AppColors.lightBlue(),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),

        ],
        navBarStyle: NavBarStyle.style7,
      ),
    );
  }
}
