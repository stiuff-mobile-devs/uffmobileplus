import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/settings_controller.dart';
import 'package:uffmobileplus/app/ui/widgets/language_selector_bottom_sheet.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(() {
          final currentLang = LanguageService.getCurrentLanguage();

          return CustomScrollView(
            slivers: [
              _sliverAppBar('configuracoes'.tr),

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
                  'Trocar Matricula',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                description: 'Alterar a matrícula vinculada ao usuário atual',
                trailing: null,
                onTap: () {
                  controller.changeMatricula();
                },
              ),

            SettingsItem(
              icon: Icon(Icons.link, color: Colors.white),
              main: Text(
                'Minhas Vinculações'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              description: 'Ver minhas autenticações ativas'.tr,
              trailing: null,
              onTap: () async {
                await controller.reloadBondStates();
                _showBondsDialog(context, controller);
              },
            ),

            // Mesma coisa aqui, o Obx escuta essa variável em tempo real
            if (controller.loginController.hasActiveGoogleBondObs.value)
              SettingsItem(
                icon: Icon(Icons.update_rounded, color: Colors.white),
                main: Text(
                  'Atualizar seus dados Google'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                description: 'Atualizar seus dados Google'.tr,
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
        )),
      ),
    );
  }
  // TODO: app bar identica à utilizada na página Sobre, extrair para um componente reutilizável
  Widget _sliverAppBar(String title) {
    return SliverAppBar(
      foregroundColor: Colors.white,
      title: Text(title),
      centerTitle: true,
      elevation: 8,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
      ),

      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
      ),

      actions: <Widget>[
        IconButton(onPressed: () {}, icon: const Icon(Icons.question_mark)),
      ],
    );
  }


  void _showBondsDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Minhas Vinculações',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  GetBuilder<SettingsController>(
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
                          SizedBox(height: 16),
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
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Fechar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            color: Colors.black.withOpacity(0.5),
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
