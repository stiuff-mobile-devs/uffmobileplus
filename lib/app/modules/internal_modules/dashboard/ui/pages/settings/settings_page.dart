import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/help_guides.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/settings_controller.dart';
import 'package:uffmobileplus/app/ui/widgets/language_selector_bottom_sheet.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(
        title: 'configuracoes'.tr,
        actions: [AppBars.helpAction(HelpGuides.configuracoes)],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(() {
          final currentLang = LanguageService.getCurrentLanguage();

          return CustomScrollView(
            slivers: [
              SettingsItem(
                icon: Icon(Icons.language, color: Colors.white),
                main: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 26,
                        height: 18,
                        child: SvgPicture.asset(
                          currentLang.flagAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      currentLang.nativeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                description: 'ling_descricao'.tr,
                trailing: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white70,
                ),
                onTap: () {
                  LanguageSelectorBottomSheet.show(context);
                },
              ),

            // O Obx fará com que este item apareça/suma automaticamente 
            // caso a vinculação mude
            if (controller.loginController.hasActiveIduffBondObs.value)
              SettingsItem(
                icon: Icon(Icons.change_circle, color: Colors.white),
                main: Text(
                  'trocar_matricula'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                description: 'trocar_matricula_descricao'.tr,
                trailing: null,
                onTap: () {
                  controller.changeMatricula();
                },
              ),

            SettingsItem(
              icon: Icon(Icons.link, color: Colors.white),
              main: Text(
                'minhas_vinculacoes'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              description: 'ver_autenticacoes_ativas'.tr,
              trailing: null,
              onTap: () async {
                await controller.reloadBondStates();
                _showBondsDialog(controller);
              },
            ),

            // Mesma coisa aqui, o Obx escuta essa variável em tempo real
            if (controller.loginController.hasActiveGoogleBondObs.value)
              SettingsItem(
                icon: Icon(Icons.update_rounded, color: Colors.white),
                main: Text(
                  'atualizar_dados_google'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                description: 'atualizar_dados_google'.tr,
                trailing: null,
                onTap: () {
                  controller.updateGoogleData();
                },
              ),

            // Botão de logout
            SettingsItem(
              icon: Icon(Icons.logout, color: Colors.white),
              main: Text(
                'sair'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              description: 'sair_descricao'.tr,
              trailing: null,
              onTap: () {
                controller.logout();
              },
            ),
          ],
          );
        }),
      ),
    );
  }
  void _showBondsDialog(SettingsController controller) {
    AppPopups.sheet<void>(
      title: 'minhas_vinculacoes'.tr,
      icon: Icons.link_rounded,
      child: GetBuilder<SettingsController>(
        builder: (ctrl) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BondStatusCard(
                name: 'IdUFF',
                hasActiveIduffBond:
                    controller.loginController.hasActiveIduffBondObs,
                color: Colors.blueAccent,
                onTap: () => controller.handleIduffBondTap(),
              ),
              const SizedBox(height: 16),
              _BondStatusCard(
                name: 'Google',
                hasActiveIduffBond:
                    controller.loginController.hasActiveGoogleBondObs,
                color: Colors.redAccent,
                onTap: () => controller.handleGoogleBondTap(),
              ),
            ],
          );
        },
      ),
      actions: (ctx) => [
        AppSheetButton.secondary(
          label: 'fechar'.tr,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  final Icon icon;
  final Widget main;
  final String description;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.main,
    required this.description,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: icon,
          title: main,
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _BondStatusCard extends StatelessWidget {
  final String name;
  final RxBool hasActiveIduffBond;
  final Color color;
  final VoidCallback? onTap;

  const _BondStatusCard({
    required this.name,
    required this.hasActiveIduffBond,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: hasActiveIduffBond.value ? color : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasActiveIduffBond.value ? color : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasActiveIduffBond.value ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
