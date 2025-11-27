import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = Get.height;
    final double width = Get.width;
    return Scaffold(
      body: Stack(
        children: [
          // Gradiente de fundo
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: AppColors.darkBlueToBlackGradient(),
            ),
          ),
          // Imagem centralizada por cima do gradiente
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: height * 0.18),
              child: Image.asset(
                'assets/logos/mini_logo_um+.png',
                fit: BoxFit.contain,
                height: height / 8,
                width: width / 4,
              ),
            ),
          ),
          // Conteúdo da página
          SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                // Top Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 75,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: "qr_code_carteirinha".tr,
                        child: InkWell(
                          onTap: controller.goToCarteirinhaPage,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                color: Colors.white,
                                size: 36,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'carteirinha_digital'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 300,
                      ), // Desce os botões
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botão único "Entrar"
                          _LoginButton(
                            text: 'entrar'.tr,
                            icon: Icons.login,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'escolha_método_login'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Passion One',
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Flexible(
                                          child: GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 18,
                                            crossAxisSpacing: 18,
                                            children: [
                                              _LoginOptionSquare(
                                                text: 'IdUFF',
                                                color: Colors.blueAccent,
                                                image:
                                                    'assets/images/uff_background2.png',
                                                onTap: controller.loginIDUFF,
                                              ),
                                              _LoginOptionSquare(
                                                text: 'Google',
                                                color: Colors.redAccent,
                                                image:
                                                    'assets/icons/google-icon.svg',
                                                onTap: controller.loginGoogle,
                                              ),
                                              _LoginOptionSquare(
                                                text: 'sem_login'.tr,
                                                color: Colors.green,
                                                image:
                                                    'assets/icons/no-login-icon.svg',
                                                svgColor: Colors.white,
                                                onTap: () {
                                                  controller.loginAnonimous();
                                                },
                                              ),/*
                                              _LoginOptionSquare(
                                                text: 'GOV',
                                                color: Colors.grey,
                                                image: 'assets/icons/gov.png',
                                                onTap:
                                                    () {}, //controller.loginGOV,
                                              ),*/
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Versão
                Padding(
                  padding: EdgeInsets.only(bottom: height / 20),
                  child: Text(
                    controller.versionCode,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _LoginButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68, // Aumenta a altura
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24), // Deixa mais largo
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18), // Mais quadrado
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Passion One',
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginOptionSquare extends StatelessWidget {
  final String text;
  final Color color;
  final String image;
  final VoidCallback onTap;
  final Color? svgColor;

  const _LoginOptionSquare({
    required this.text,
    required this.color,
    required this.image,
    required this.onTap,
    this.svgColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (image.toLowerCase().endsWith('.svg')) {
      imageWidget = SvgPicture.asset(
        image,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        color: svgColor,
      );
    } else {
      imageWidget = Image.asset(
        image,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            color: Colors.black.withOpacity(0.65),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(child: imageWidget),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Passion One',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
