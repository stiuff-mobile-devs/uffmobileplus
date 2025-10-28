import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class HomePage extends GetView<HomePageController> {
  @override
  Widget build(BuildContext context) {
    Get.appendTranslations({
      'pt_BR': {
        'boas-vindas': 'Bem-vindo ao novo',
        'em_desenvolvimento': 'Aplicativo em desenvolvimento',
        'trab_constante': 'Estamos trabalhando constantemente para oferecer a melhor experiência possível. Aguarde as próximas atualizações!',
        'versao': 'Versão'
      },
      'en_US': {
        'boas-vindas' : 'Welcome to the new',
        'em_desenvolvimento': 'App under development',
        'trab_constante': 'We are constantly working to deliver the best possible experience. Look forward to the next updates!',
        'versao': 'Version'
      }
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: const Text("UM +"),
        actions: [
          IconButton(
            icon: const Icon(Icons.question_mark),
            tooltip: 'Ajuda',
            onPressed: () {},
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
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícone de boas-vindas
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.waving_hand,
                            size: 60,
                            color: Colors.amber[300],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Título principal
                        Text(
                          'boas-vindas'.tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Logo do UM+
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Colors.blue[300]!, Colors.purple[300]!],
                          ).createShader(bounds),
                          child: Text(
                            'UM+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Mensagem de desenvolvimento
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.construction,
                                color: Colors.orange[300],
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'em_desenvolvimento'.tr,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'trab_constante'.tr,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Logo da aplicação
                        const SizedBox(height: 16),

                        // Versão
                        Text(
                          'versao'.tr + ' 6.4.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
