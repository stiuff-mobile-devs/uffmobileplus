import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/help_guides.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/settings_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/widgets/menu_tile.dart';
import 'package:uffmobileplus/app/ui/widgets/language_selector_bottom_sheet.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
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
          final login = controller.loginController;
          final hasIduff = login.hasActiveIduffBondObs.value;
          final hasGoogle = login.hasActiveGoogleBondObs.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              MenuSectionHeader('conta'.tr),
              MenuTile(
                icon: Icons.link_rounded,
                title: 'minhas_vinculacoes'.tr,
                subtitle: 'ver_autenticacoes_ativas'.tr,
                onTap: () async {
                  await controller.reloadBondStates();
                  _showBondsDialog(controller);
                },
              ),
              if (hasIduff)
                MenuTile(
                  icon: Icons.swap_horiz_rounded,
                  title: 'trocar_matricula'.tr,
                  subtitle: 'trocar_matricula_descricao'.tr,
                  onTap: controller.changeMatricula,
                ),
              if (hasGoogle)
                MenuTile(
                  icon: Icons.sync_rounded,
                  title: 'atualizar_dados_google'.tr,
                  subtitle: 'atualizar_dados_google_desc'.tr,
                  onTap: controller.updateGoogleData,
                ),

              MenuSectionHeader('preferencias'.tr),
              LanguageMenuTile(
                onTap: () => LanguageSelectorBottomSheet.show(context),
              ),

              const SizedBox(height: 16),
              MenuTile(
                icon: Icons.logout_rounded,
                title: 'sair'.tr,
                subtitle: 'sair_descricao'.tr,
                destructive: true,
                trailing: const SizedBox.shrink(),
                onTap: controller.confirmLogout,
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
                  hasActiveIduffBond.value ? 'ativo'.tr : 'inativo'.tr,
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
