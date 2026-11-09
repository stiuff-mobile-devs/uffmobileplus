import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/controller/auth_iduff_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

/// Tela exibida durante o login IdUFF. Usa sempre o fundo escuro do app para
/// nunca aparecer uma tela branca entre o navegador de login e o carregamento.
class AuthIduffPage extends GetView<AuthIduffController> {
  const AuthIduffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CustomProgressDisplay())
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}
