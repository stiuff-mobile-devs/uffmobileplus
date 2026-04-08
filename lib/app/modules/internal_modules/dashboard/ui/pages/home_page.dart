import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: const Text('UFF +'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'ajuda'.tr,
            onPressed: () => Get.toNamed(Routes.CENTRAL_DE_ATENDIMENTO),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),
          child: controller.isLoading.value
              ? const Center(child: CustomProgressDisplay())
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUpdateBanner(),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Atalhos rápidos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showAddShortcutSheet(context),
                              tooltip: 'Adicionar atalho',
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: controller.toggleRemoveShortcutMode,
                              tooltip: 'Remover atalho',
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: controller.isRemovingShortcuts.value
                                      ? Colors.red.withOpacity(0.25)
                                      : Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Acesso direto aos serviços mais usados no seu dia a dia.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.savedShortcuts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final item = controller.savedShortcuts[index];
                            return _ShortcutCard(
                              item: item,
                              isRemoveMode:
                                  controller.isRemovingShortcuts.value,
                              onTap: () {
                                if (controller.isRemovingShortcuts.value) {
                                  controller.removeShortcut(item);
                                  return;
                                }

                                controller.openShortcut(item);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                       
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildUpdateBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF5EE5FF), Color(0xFF2EA1FF), Color(0xFF0B4CD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5533AAFF),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -20,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -16,
            child: Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFF031B53).withOpacity(0.35),
                  ),
                  child: const Text(
                    'NOVA ATUALIZACAO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bem-vindo a nova atualizacao do UFF Mobile Plus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atalhos mais inteligentes, visual renovado e uma navegacao mais rapida para voce.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddShortcutSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkBlue(),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Obx(() {
          final remainingServices = controller.availableToAdd;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adicionar atalho',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.96),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Serviços ainda não salvos na sua grade.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (remainingServices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Todos os serviços já estão na sua grade.',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: remainingServices.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.white.withOpacity(0.12),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final service = remainingServices[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _ServiceIcon(iconSrc: service.iconSrc),
                            title: Text(
                              service.subtitle,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),
                              onPressed: () => controller.addShortcut(service),
                            ),
                            onTap: () => controller.addShortcut(service),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerProfileHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  children: [
                    _DrawerTile(
                      icon: Icons.settings_outlined,
                      title: 'Configurações',
                      subtitle: 'Ajustes do aplicativo',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(Routes.SETTINGS);
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.info_outline,
                      title: 'Sobre',
                      subtitle: 'Informações do app e versão',
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

  Widget _buildDrawerProfileHeader() {
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

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.item,
    required this.onTap,
    required this.isRemoveMode,
  });

  final DashboardShortcut item;
  final VoidCallback onTap;
  final bool isRemoveMode;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ServiceIcon(iconSrc: item.iconSrc),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 24,
                    child: Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isRemoveMode)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.iconSrc});

  final String iconSrc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: AppColors.lightBlue().withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: iconSrc.endsWith('.svg')
            ? SvgPicture.asset(
                iconSrc,
                color: Colors.white,
                fit: BoxFit.contain,
              )
            : Image.asset(iconSrc, color: Colors.white, fit: BoxFit.contain),
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
