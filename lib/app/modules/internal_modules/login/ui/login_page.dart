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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      _BreathingLogoBox(height: 76, width: 228),
                      const SizedBox(height: 16),
                      Text(
                        'Universidade Federal Fluminense',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.42),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF2EA1FF).withOpacity(0.6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2EA1FF).withOpacity(0.18),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'escolha_método_login'.tr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: 0.9,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Obx(
                                  () => _LoginOptionButton(
                                    text: 'IdUFF',
                                    color:
                                        controller.hasActiveIduffBondObs.value
                                        ? Colors.blueAccent
                                        : Colors.grey,
                                    image: 'assets/images/uff_background2.png',
                                    onTap: controller.loginIDUFF,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Obx(
                                  () => _LoginOptionButton(
                                    text: 'Google',
                                    color:
                                        controller.hasActiveGoogleBondObs.value
                                        ? Colors.redAccent
                                        : Colors.grey,
                                    image: 'assets/icons/google-icon.svg',
                                    onTap: controller.loginGoogle,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LoginOptionButton(
                                  text: 'sem_login'.tr,
                                  color: Colors.green,
                                  image: 'assets/icons/no-login-icon.svg',
                                  svgColor: Colors.white,
                                  onTap: controller.loginAnonimous,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickActionChip(
                            tooltip: 'qr_code_carteirinha'.tr,
                            icon: Icons.qr_code_2,
                            label: 'carteirinha_digital'.tr,
                            onTap: controller.goToCarteirinhaPage,
                          ),
                          Obx(
                            () => controller.hasAdminPermission.value
                                ? _QuickActionChip(
                                    tooltip: 'qr_code_catraca'.tr,
                                    icon: Icons.qr_code_scanner,
                                    label: 'Catraca'.tr,
                                    onTap: controller.goToCatracaOnlinePage,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        controller.versionCode,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.32),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Image.asset(
        'assets/images/background-login.png',
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Image.asset(
              'assets/logos/mini_logo_um+.png',
              fit: BoxFit.contain,
              height: widget.height,
              width: widget.width,
            ),
          ),
        );
      },
    );
  }
}

class _LoginOptionButton extends StatelessWidget {
  final String text;
  final Color color;
  final String image;
  final VoidCallback onTap;
  final Color? svgColor;

  const _LoginOptionButton({
    required this.text,
    required this.color,
    required this.image,
    required this.onTap,
    this.svgColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = color != Colors.grey;
    Widget imageWidget;
    if (image.toLowerCase().endsWith('.svg')) {
      imageWidget = SvgPicture.asset(
        image,
        fit: BoxFit.cover,
        width: 30,
        height: 30,
        color: svgColor,
      );
    } else {
      imageWidget = Image.asset(
        image,
        fit: BoxFit.cover,
        width: 30,
        height: 30,
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 68,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? color.withOpacity(0.6)
                  : Colors.white.withOpacity(0.16),
              width: 1,
            ),
            color: Colors.white.withOpacity(0.04),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
                child: ClipOval(child: imageWidget),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.55),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
