import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class CustomDrawer extends GetView<HomePageController> {
  const CustomDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _profileHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  children: [
                    _DrawerTile(
                      icon: Icons.settings_outlined,
                      title: 'configuracoes'.tr,
                      subtitle: 'ajustes_do_aplicativo'.tr,
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(Routes.SETTINGS);
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.wifi,
                      title: 'conexoes'.tr,
                      subtitle: 'informacoes_sobre_infraestruturas'.tr,
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(Routes.CONNECTIONS);
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.info_outline,
                      title: 'sobre'.tr,
                      subtitle: 'informacoes_app_versao'.tr,
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(Routes.ABOUT);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              AppColors.mediumBlue().withOpacity(0.95),
              AppColors.darkBlue().withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
              clipBehavior: Clip.antiAlias,
              child: controller.userPhotoUrl.value.isNotEmpty
                  ? Image.network(
                      controller.userPhotoUrl.value,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    )
                  : const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.96),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller.userMatricula.value.isNotEmpty ||
                      controller.userMatricula.value != '')
                    Text(
                      'Matrícula: ${controller.userMatricula.value}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    controller.userEmail.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 12,
                    ),
                  ),
                  if (controller.userCourse.value.isNotEmpty ||
                      controller.userCourse.value != '')
                    Text(
                      controller.userCourse.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.lightBlue().withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.lightBlue(), size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.45),
          ),
        ),
      ),
    );
  }
}
