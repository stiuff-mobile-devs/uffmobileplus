import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class LockDevelopModePage extends StatelessWidget {
  const LockDevelopModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 196, 43, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black, size: 28),
            onPressed: () async {
              Get.toNamed(
                Routes.WEB_VIEW,
                arguments: {
                  'url': Secrets.helpUrl,
                  'title': 'modo_desenvolvedor'.tr,
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          Get.offAllNamed(Routes.SPLASH);
        },
        color: Colors.black,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/you_shall_not_pass.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'desativar_modo_desenvolvedor'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      switch (OpenSettingsPlus.shared) {
                        case OpenSettingsPlusAndroid settings:
                          await settings.applicationDevelopment();
                          break;
                        case OpenSettingsPlusIOS settings:
                          await settings.general();
                          break;
                        default:
                          throw Exception('Platform not supported');
                      }
                    } catch (e) {
                      // Fallback para configurações gerais se falhar
                      try {
                        switch (OpenSettingsPlus.shared) {
                          case OpenSettingsPlusAndroid settings:
                            await settings.appSettings();
                            break;
                          case OpenSettingsPlusIOS settings:
                            await settings.general();
                            break;
                          default:
                            Get.snackbar(
                              'erro'.tr,
                              'plataforma_nao_suportada'.tr,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'erro'.tr,
                          'nao_foi_possivel_abrir_as_configuracoes'.tr,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('configuracoes'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
