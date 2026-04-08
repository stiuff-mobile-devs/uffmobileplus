import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
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
          _AnimatedLoginBackdrop(width: width, height: height),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: height * 0.18),
              child: _BreathingLogoBox(
                height: height / 8,
                width: width / 4,
              ),
            ),
          ),
          SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
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
                              const Icon(
                                Icons.qr_code_2,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'carteirinha_digital'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      Obx(
                        () => controller.hasAdminPermission.value
                            ? Tooltip(
                                message: "qr_code_catraca".tr,
                                child: InkWell(
                                  onTap: controller.goToCatracaOnlinePage,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.qr_code_scanner,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Catraca'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                          style: const TextStyle(
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
                                              Obx(
                                                () => _LoginOptionSquare(
                                                  text: 'IdUFF',
                                                  color: controller
                                                          .hasActiveIduffBondObs
                                                          .value
                                                      ? Colors.blueAccent
                                                      : Colors.grey,
                                                  image:
                                                      'assets/images/uff_background2.png',
                                                  onTap: controller.loginIDUFF,
                                                ),
                                              ),
                                              Obx(
                                                () => _LoginOptionSquare(
                                                  text: 'Google',
                                                  color: controller
                                                          .hasActiveGoogleBondObs
                                                          .value
                                                      ? Colors.redAccent
                                                      : Colors.grey,
                                                  image:
                                                      'assets/icons/google-icon.svg',
                                                  onTap: controller.loginGoogle,
                                                ),
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
                                              ),
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
                Padding(
                  padding: EdgeInsets.only(bottom: height / 20),
                  child: Text(
                    controller.versionCode,
                    style: const TextStyle(color: Colors.white),
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

class _AnimatedLoginBackdrop extends StatefulWidget {
  const _AnimatedLoginBackdrop({required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<_AnimatedLoginBackdrop> createState() => _AnimatedLoginBackdropState();
}

class _AnimatedLoginBackdropState extends State<_AnimatedLoginBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final phase = 2 * math.pi * t;
        final x1 = math.sin(phase) * 12;
        final y1 = math.cos(phase) * 10;
        final x2 = math.cos(phase * 0.85) * 14;
        final y2 = math.sin(phase * 0.85) * 12;

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF02040B),
                      Color(0xFF07162A),
                      Color(0xFF0B2A52),
                      Color(0xFF02040B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.38, 0.72, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: -70 + y1,
                right: -50 + x1,
                child: _GlowBlob(
                  size: 230,
                  colors: [
                    const Color(0xFF2EA1FF).withOpacity(0.28),
                    const Color(0xFF2EA1FF).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              Positioned(
                bottom: widget.height * 0.18 + y2,
                left: -60 + x2,
                child: _GlowBlob(
                  size: 240,
                  colors: [
                    const Color(0xFF5EE5FF).withOpacity(0.16),
                    const Color(0xFF5EE5FF).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              
            ],
          ),
        );
      },
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          stops: const [0.0, 0.55, 1.0],
        ),
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

class _BreathingLogoBox extends StatefulWidget {
  const _BreathingLogoBox({required this.height, required this.width});

  final double height;
  final double width;

  @override
  State<_BreathingLogoBox> createState() => _BreathingLogoBoxState();
}

class _BreathingLogoBoxState extends State<_BreathingLogoBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(curved);
    _opacityAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
        final glowOpacity = 0.12 + (pulse * 0.14);
        final ringOpacity = 0.10 + (pulse * 0.10);

        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox.square(
              dimension: 182,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 182,
                    height: 182,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2EA1FF).withOpacity(glowOpacity),
                          const Color(0xFF5EE5FF).withOpacity(glowOpacity * 0.55),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.62, 1.0],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: 156,
                        height: 156,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2EA1FF).withOpacity(0.20),
                              blurRadius: 26,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 138,
                    height: 138,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withOpacity(ringOpacity),
                        width: 1,
                      ),
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.18),
                          const Color(0xFF5EE5FF).withOpacity(0.12),
                          const Color(0xFF0B2A52).withOpacity(0.08),
                        ],
                        stops: const [0.0, 0.58, 1.0],
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/logos/mini_logo_um+.png',
                    fit: BoxFit.contain,
                    height: widget.height * 0.80,
                    width: widget.width * 0.80,
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
