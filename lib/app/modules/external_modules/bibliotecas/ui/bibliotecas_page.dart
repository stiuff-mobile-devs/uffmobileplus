import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/bibliotecas/controller/bibliotecas_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart'; // g

class BibliotecasPage extends StatelessWidget { 
  const BibliotecasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 8,
          foregroundColor: Colors.white,
          title: Text('bibliotecas'.tr),
          flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      backgroundColor: AppColors.lightBlue(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        // Adicionamos o GetBuilder com o init para instanciar o Controller
        child: GetBuilder<BibliotecasController>(
          init: BibliotecasController(), 
          builder: (controller) {
            return Obx(() {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return bibliotecasModulesWidget(
                          controller.bibliotecasModulesList[index],
                          controller,
                          context,
                        );
                      }, childCount: controller.bibliotecasModulesList.length),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                      ),
                    ),
                  ),
                ],
              );
            });
          }
        ),
      )
    );
  }

  Widget bibliotecasModulesWidget(
    BibliotecasModules bibliotecaModule,
    BibliotecasController controller,
    BuildContext context,
  ) {
    Widget module = GestureDetector(
      child: InkWell(
        splashColor: Colors.blue.withOpacity(0.2),
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          controller.navigateTo(
            bibliotecaModule.page,
            interrogation: bibliotecaModule.interrogation ?? false,
            webViewUrl: bibliotecaModule.url ?? '',
            appBarTitle: bibliotecaModule.subtitle,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconVisualEffect(
              child: SvgPicture.asset(
                bibliotecaModule.iconSrc,
                width: 50,
                height: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text(
                bibliotecaModule.subtitle.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
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
        gradient: RadialGradient(
          colors: [
            Colors.cyan.withOpacity(0.4),
            Colors.blue.withOpacity(0.2),
            AppColors.darkBlue().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(42.5),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 1.5),
      ),
      child: Center(child: child),
    );
  }
}