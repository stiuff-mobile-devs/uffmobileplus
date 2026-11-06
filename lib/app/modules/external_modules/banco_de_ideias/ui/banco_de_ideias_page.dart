import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/module_access.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/usuario_atual.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/home/ui/banco_de_ideias_home_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/registration/ui/registration_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/auth/ui/login_page.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class BancoDeIdeiasPage extends GetView<BancoDeIdeiasController> {
  const BancoDeIdeiasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BancoDeIdeiasController>(
      builder: (controller) => FutureBuilder<ModuleAccess>(
        future: controller.checkModuleAccess(),
        builder: (context, accessSnapshot) {
          if (accessSnapshot.connectionState == ConnectionState.waiting) {
            return const _BancoDeIdeiasLoading();
          }

          if (accessSnapshot.hasError) {
            return _BancoDeIdeiasAccessNotice(
              title: 'bdi_titulo'.tr,
              message: 'bdi_verificacao_acesso_erro'.tr,
              icon: Icons.error_outline_rounded,
              actionLabel: 'tentar_novamente'.tr,
              actionIcon: Icons.refresh_rounded,
              onAction: controller.retryModuleAccess,
            );
          }

          if (accessSnapshot.data == ModuleAccess.googleLoginRequired) {
            return const LoginPage();
          }

          if (accessSnapshot.data != ModuleAccess.allowed) {
            return const _BancoDeIdeiasRestrictedAccess();
          }

          return StreamBuilder(
            stream: controller.authService.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _BancoDeIdeiasLoading();
              }

              if (user == null) {
                controller.loadedUid = null;
                controller.usuarioFuture = null;
                return const LoginPage();
              }

              controller.prepareLoggedUser(user.uid);

              return FutureBuilder<UsuarioAtual?>(
                future: controller.usuarioFuture,
                builder: (context, usuarioSnapshot) {
                  if (usuarioSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _BancoDeIdeiasLoading();
                  }

                  if (usuarioSnapshot.hasError) {
                    return _BancoDeIdeiasError(
                      error: usuarioSnapshot.error,
                      onRetry: controller.reloadUsuario,
                      onSignOut: controller.signOut,
                    );
                  }

                  if (usuarioSnapshot.data == null) {
                    return const RegistrationPage();
                  }

                  return const BancoDeIdeiasHomePage();
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _BancoDeIdeiasLoading extends GetView<BancoDeIdeiasController> {
  const _BancoDeIdeiasLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.lightBlue()),
        ),
      ),
    );
  }
}

class _BancoDeIdeiasRestrictedAccess extends GetView<BancoDeIdeiasController> {
  const _BancoDeIdeiasRestrictedAccess();

  @override
  Widget build(BuildContext context) {
    return _BancoDeIdeiasAccessNotice(
      title: 'bdi_acesso_restrito'.tr,
      message: 'bdi_sem_permissao_msg'.tr,
      icon: Icons.lock_outline_rounded,
      actionLabel: 'bdi_solicitar_acesso'.tr,
      onAction: controller.solicitarAcesso,
    );
  }
}

class _BancoDeIdeiasAccessNotice extends GetView<BancoDeIdeiasController> {
  const _BancoDeIdeiasAccessNotice({
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.actionIcon = Icons.open_in_new_rounded,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bdi_titulo'.tr),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(icon, size: 52, color: AppColors.lightBlue()),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (onAction != null) ...[
                        FilledButton.icon(
                          onPressed: onAction,
                          icon: Icon(actionIcon),
                          label: Text(actionLabel!),
                        ),
                        const SizedBox(height: 8),
                      ],
                      FilledButton.icon(
                        onPressed: Get.back,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text('voltar'.tr),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BancoDeIdeiasError extends GetView<BancoDeIdeiasController> {
  const _BancoDeIdeiasError({
    required this.error,
    required this.onRetry,
    required this.onSignOut,
  });

  final Object? error;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bdi_titulo'.tr),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.lightBlue(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'bdi_nao_foi_possivel_carregar_usuario'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text('tentar_novamente'.tr),
                    ),
                    TextButton.icon(
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: Text('sair'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
