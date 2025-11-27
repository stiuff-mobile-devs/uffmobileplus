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
                  icon: Icon(Icons.change_circle, color: Colors.white,),
                   main: Text('Trocar Matricula', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                    description: 'Alterar a matrícula vinculada ao usuário atual',
                    trailing: null,
                    onTap: () {
                      controller.changeMatricula();
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
