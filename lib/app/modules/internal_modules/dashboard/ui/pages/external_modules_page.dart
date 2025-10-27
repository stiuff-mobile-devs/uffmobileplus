import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

// Página que exibe uma grade de serviços externos disponíveis no aplicativo
class ExternalModulesPage extends StatelessWidget {
  const ExternalModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.appendTranslations({
      'pt_BR' : {
        'servicos' : 'Serviços',
      },
      'en_US' : {
        'servicos' : 'Services',
      },
      'it_IT' : {
        'servicos' : 'Servizi'
      }
    });
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: GetBuilder<ExternalModulesController>(
          init: ExternalModulesController(),
          builder: (controller) {
            return Builder(
              builder: (context) {
                return CustomScrollView(
                  slivers: [
                    // AppBar que se comporta como uma sliver (pode ser expandida/colapsada)
                    SliverAppBar(
                      foregroundColor: Colors.white,
                      title: Text('servicos'.tr),
                      centerTitle: true,
                      elevation: 8, // Sombra da AppBar

                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                      ),
                      flexibleSpace: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.appBarTopGradient(),
                        ),
                      ),

                      // Botão de ajuda/documentação
                      actions: <Widget>[
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.question_mark),
                        ),
                      ],
                    ),

                    // Padding ao redor da grade de serviços
                    SliverPadding(
                      padding: const EdgeInsets.all(20),

                      // Grade de serviços
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return externalModulesWidget(
                            controller.externalModulesList[index],
                            controller,
                            context,
                          );
                        }, childCount: controller.externalModulesList.length),

                        // Define grade com 3 colunas fixas
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Widget que representa um serviço individual na grade
  Widget externalModulesWidget(
    ExternalModules externalModule,
    ExternalModulesController controller,
    BuildContext context,
  ) {
    // Verifica se o serviço está em construção
    //bool underContruction = externalModule.page == Routes.UNDER_CONSTRUCTION;

    Widget module = GestureDetector(
      /* Atalho desativado temporariamente

        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('Criar atalho'),
              content: Text(
                  'Deseja criar um atalho para "${externalModule.subtitle}"?',
                  style: const TextStyle(fontSize: 16)),
              actions: [
                // Botão cancelar
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar',
                      style: TextStyle(
                        color: AppColors.darkBlue(),
                        fontSize: 16,
                      )),
                ),
                // Botão confirmar - salva o atalho
                TextButton(
                  onPressed: () {
                    QuickAccessRepository.saveShortcut(
                      QuickAccessShortcut(
                        title: service.subtitle,
                        page: service.page,
                        iconSrc: service.iconSrc,
                        url: service.url,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Confirmar',
                      style: TextStyle(
                          color: AppColors.darkBlue(),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        */

      // InkWell fornece efeito visual de toque
      child: InkWell(
        splashColor: Colors.blue.withOpacity(0.2),

        // Ação executada no toque
        onTap: () async {
          /*if (underContruction) {
              // Mostra alerta se serviço está em construção
              customAlertDialog(context, title: 'page_under_development'.tr)
                  .show();
            } else {
              // Pequeno delay para melhor UX



              // Navega para o serviço
              controller.navigateTo(service.page,
                  interrogation: service.interrogation ?? false,
                  webViewUrl: service.url!,
                  appBarTitle: service.subtitle);
            }*/

          await Future.delayed(const Duration(milliseconds: 100));
          // Navega para o serviço
          controller.navigateTo(
            externalModule.page,
            interrogation: externalModule.interrogation ?? false,
            webViewUrl: externalModule.url!,
            appBarTitle: externalModule.subtitle,
          );
        },

        // Layout do serviço: ícone + texto
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container para efeito
            iconVisualEffect(
              child: SvgPicture.asset(
                externalModule.iconSrc,
                width: 50,
                height: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10), // Espaçamento
            // Título/subtítulo do serviço
            Align(
              alignment: Alignment.center,
              child: Text(
                externalModule.subtitle.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    return module;
  }

  Widget iconVisualEffect({required Widget child}) {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        // Fundo com gradiente circular
        gradient: RadialGradient(
          colors: [
            Colors.cyan.withOpacity(0.4),
            Colors.blue.withOpacity(0.2),
            AppColors.darkBlue().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(42.5),
        // Múltiplas sombras para efeito neon
        boxShadow: [
          // Brilho interno azul
          BoxShadow(
            color: Colors.cyan.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          // Brilho externo
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          // Highlight branco sutil
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        // Borda brilhante
        border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 1.5),
      ),
      child: Center(child: child),
    );
  }
}
