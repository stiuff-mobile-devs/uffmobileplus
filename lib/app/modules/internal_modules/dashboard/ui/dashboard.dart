import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/external_modules_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/home_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/settings/settings_page.dart';
import 'package:uffmobileplus/app/utils/base_translation_keys.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class Dashboard extends GetView<DashboardController> {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: controller.tabController,
        screens: [HomePage(), ExternalModulesPage(), SettingsPage()],
        items: [
          // Tela Principal
          PersistentBottomNavBarItem(
            icon: Icon(Icons.phonelink_setup),
            title: BaseTranslationKeys.shortcuts.tr,
            activeColorPrimary: AppColors.lightBlue(),
            inactiveColorPrimary: Colors.grey,
            activeColorSecondary: Colors.black,
          ),

          // Tela de Serviços
          PersistentBottomNavBarItem(
            icon: Icon(Icons.business),
            title: BaseTranslationKeys.modules.tr,
            activeColorPrimary: AppColors.lightBlue(),
            inactiveColorPrimary: Colors.black,
            activeColorSecondary: Colors.black,
          ),

          // Tela de Configurações
          PersistentBottomNavBarItem(
            icon: Icon(Icons.settings),
            title: BaseTranslationKeys.settings.tr,
            activeColorPrimary: AppColors.lightBlue(),
            inactiveColorPrimary: Colors.grey,
            activeColorSecondary: Colors.black,
          ),
        ],
        navBarStyle: NavBarStyle.style7,
      ),
    );
  }
}
