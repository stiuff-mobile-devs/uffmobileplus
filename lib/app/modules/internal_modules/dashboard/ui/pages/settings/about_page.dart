import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/about_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.appendTranslations({
      'pt_BR' : {
        'titulo' : 'Sobre',
        'nome_versao' : 'Nome da versão',
        'codigo_versao' : 'Código da versão',
        'dispositivo' : 'Dispositivo'
      },
      'en_US' : {
        'titulo' : 'About',
        'nome_versao' : 'Version name',
        'codigo_versao' : 'Version code',
        'dispositivo' : 'Device'
      },
      'it_IT' : {
        'titulo' : 'Informazioni',
        'nome_versao' : 'Versione',
        'codigo_versao' : 'Codice build',
        'dispositivo' : 'Dispositivo'
      }
    });
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: GetBuilder<AboutController>(
          init: AboutController(),
          builder: (controller) {
            return CustomScrollView(
              slivers: [
                _sliverAppBar('titulo'.tr),
                _aboutItemCard(
                  Icons.home,
                  'nome_versao'.tr,
                  controller.versionName,
                ),
                _aboutItemCard(
                  Icons.update,
                  'codigo_versao'.tr,
                  controller.versionCode,
                ),
                _aboutItemCard(
                  Icons.phone_android,
                  'dispositivo'.tr,
                  controller.device,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // TODO: app bar identica à utilizada na página Configurações, extrair para um componente reutilizável
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

  // Widget individual para cada item na lista exibida na página "Sobre"
  Widget _aboutItemCard(IconData icon, String title, String description) {
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
        ),
      ),
    );
  }
}
