import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/settings_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SettingsController>(
        builder: (SettingsController controller) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.darkBlueToBlackGradient(),
            ),
            child: CustomScrollView(
              slivers: [
                _sliverAppBar('configuracoes'.tr),
                // TODO: substituir por SettingsItem
                _settingsItem(
                  Icons.info_outline,
                  'sobre'.tr,
                  'sobre_descricao'.tr,
                  onTap: () {
                    Get.toNamed(Routes.ABOUT);
                  },
                ),
                SettingsItem(
                  icon: Icon(Icons.language, color: Colors.white),
                  main: DropdownButton<Locale>(
                    value: Get.locale,
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    underline: Container(), // Remove underline
                    // Ao suportar um novo idioma, adicionar novo par
                    // na lista abaixo
                    // TODO: extrair essa lista para algum outro lugar?
                    items:
                        [
                          {
                            'locale': Locale('pt', 'BR'),
                            'display': 'Português (BR)',
                          },
                          {
                            'locale': Locale('en', 'US'),
                            'display': 'English (US)',
                          },
                          {
                            'locale': Locale('it', 'IT'),
                            'display': 'Italiano (IT)',
                          },
                        ].map((item) {
                          Locale locale = item['locale'] as Locale;
                          String displayString = item['display'] as String;

                          return DropdownMenuItem<Locale>(
                            value: locale,
                            child: Text(displayString),
                          );
                        }).toList(),
                    onChanged: (Locale? newValue) {
                      if (newValue != null) Get.updateLocale(newValue);
                    },
                  ),
                  description: 'ling_descricao'.tr,
                  trailing: null, // No chevron needed since it's a dropdown
                ),
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
                    controller.logoutIduff();
                  },
                ),
              ],
            ),
          );
        },
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

  Widget _settingsItem(
    IconData icon,
    String title,
    String description, {
    VoidCallback? onTap,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.white70),
          onTap: onTap,
        ),
      ),
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
                                controller.hasActiveIduffBondObs,
                            color: Colors.blueAccent,
                            onTap: () => controller.handleIduffBondTap(),
                          ),
                          SizedBox(height: 16),
                          _BondStatusCard(
                            name: 'Google',
                            hasActiveIduffBond:
                                controller.hasActiveGoogleBondObs,
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
