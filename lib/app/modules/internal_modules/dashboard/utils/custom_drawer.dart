import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/widgets/menu_tile.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/ui/widgets/language_selector_bottom_sheet.dart';
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            children: [
              _ProfileCard(controller: controller),
              const SizedBox(height: 12),
              LanguageMenuTile(
                onTap: () => LanguageSelectorBottomSheet.show(context),
              ),
              MenuTile(
                icon: Icons.settings_outlined,
                title: 'configuracoes'.tr,
                subtitle: 'ajustes_do_aplicativo'.tr,
                onTap: () {
                  Navigator.of(context).pop();
                  Get.toNamed(Routes.SETTINGS);
                },
              ),
              const _SwitchTabMenuTile(),
              MenuTile(
                icon: Icons.wifi,
                title: 'conexoes'.tr,
                subtitle: 'informacoes_sobre_infraestruturas'.tr,
                onTap: () {
                  Navigator.of(context).pop();
                  Get.toNamed(Routes.CONNECTIONS);
                },
              ),
              MenuTile(
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
      ),
    );
  }
}

/// Card do usuário no topo do menu. Com o IdUFF ativo vira uma mini
/// carteirinha que abre a carteirinha digital; sem ele, um card simples.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final HomePageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final login = Get.isRegistered<LoginController>()
          ? Get.find<LoginController>()
          : null;
      final hasIduff = login?.hasActiveIduffBondObs.value ?? false;

      final name = controller.userName.value;
      final photoUrl = controller.userPhotoUrl.value;

      if (hasIduff) {
        return _StudentIdCard(
          name: name,
          matricula: controller.userMatricula.value,
          course: controller.userCourse.value,
          photoUrl: photoUrl,
        );
      }
      return _SimpleProfileCard(
        name: name,
        email: controller.userEmail.value,
        photoUrl: photoUrl,
      );
    });
  }
}

const Color _primaryText = Color(0xF5FFFFFF); // branco 96%
const Color _secondaryText = Color(0xBFFFFFFF); // branco 75%

/// Mini carteirinha: faixa com o logo da UFF + foto 3:4, nome, matrícula e
/// curso. O card inteiro abre a carteirinha digital.
class _StudentIdCard extends StatelessWidget {
  const _StudentIdCard({
    required this.name,
    required this.matricula,
    required this.course,
    required this.photoUrl,
  });

  final String name;
  final String matricula;
  final String course;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      label: 'carteirinha_digital'.tr,
      child: Material(
        color: AppColors.darkBlue(),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            Get.toNamed(Routes.CARTEIRINHA_DIGITAL);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AppColors.mediumBlue(),
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/carteirinha_digital/images/uff_logo.png',
                      height: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'carteirinha_digital'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _primaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: _primaryText),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _Avatar(photoUrl: photoUrl, rectangular: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome completo, quebrando em quantas linhas precisar.
                          Text(
                            name.toUpperCase(),
                            style: const TextStyle(
                              color: _primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (matricula.isNotEmpty)
                            _InfoLine(
                              'matricula_label'.trParams({
                                'matricula': matricula,
                              }),
                            ),
                          if (course.isNotEmpty) _InfoLine(course),
                        ],
                      ),
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
}

/// Sem IdUFF (Google ou visitante): só exibe os dados, sem ação.
class _SimpleProfileCard extends StatelessWidget {
  const _SimpleProfileCard({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  final String name;
  final String email;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    // Visitante chega com nome vazio ou com os marcadores "--"/"-".
    final hasName = name.isNotEmpty && name != '--' && name != '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _Avatar(photoUrl: photoUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? name : 'sem_login'.tr,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (email.isNotEmpty && email != '-') _InfoLine(email),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _secondaryText, fontSize: 12),
      ),
    );
  }
}

/// Foto do usuário: circular (card simples) ou 3:4 como em documento.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, this.rectangular = false});

  final String photoUrl;
  final bool rectangular;

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(
      Icons.person_outline,
      color: Colors.white,
      size: 26,
    );

    return Container(
      width: rectangular ? 56 : 44,
      height: rectangular ? 72 : 44,
      decoration: BoxDecoration(
        shape: rectangular ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: rectangular ? BorderRadius.circular(8) : null,
        color: Colors.white.withValues(alpha: 0.12),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl.isNotEmpty
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            )
          : placeholder,
    );
  }
}

/// Alterna entre as abas da dashboard: na Home leva a todos os serviços e em
/// Serviços volta para a Home.
class _SwitchTabMenuTile extends StatelessWidget {
  const _SwitchTabMenuTile();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      return const SizedBox.shrink();
    }
    final dashboard = Get.find<DashboardController>();

    return Obx(() {
      final onHome =
          dashboard.currentIndex.value == DashboardController.homeTab;
      return MenuTile(
        icon: onHome ? Icons.apps_rounded : Icons.home_rounded,
        title: onHome ? 'todos_os_servicos'.tr : 'voltar_pagina_inicial'.tr,
        subtitle: onHome
            ? 'ver_todos_servicos_desc'.tr
            : 'voltar_pagina_inicial_desc'.tr,
        onTap: () {
          Navigator.of(context).pop();
          dashboard.goToTab(
            onHome ? DashboardController.servicesTab : DashboardController.homeTab,
          );
        },
      );
    });
  }
}
