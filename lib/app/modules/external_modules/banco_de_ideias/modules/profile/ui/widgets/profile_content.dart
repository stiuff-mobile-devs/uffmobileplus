import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/usuario_atual.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_state_widgets.dart';

class ProfileContent extends GetView<BancoDeIdeiasController> {
  const ProfileContent({
    super.key,
    required this.future,
    required this.onRetry,
    required this.onOpenAdminPanel,
    required this.onSignOut,
  });

  final Future<UsuarioAtual?> future;
  final VoidCallback onRetry;
  final VoidCallback onOpenAdminPanel;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UsuarioAtual?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        if (snapshot.hasError) {
          return ErrorState(error: snapshot.error, onRetry: onRetry);
        }

        final usuario = snapshot.data;
        if (usuario == null) {
          return EmptyState(message: 'bdi_usuario_nao_cadastrado'.tr);
        }

        return ProfileCard(
          usuario: usuario,
          onOpenAdminPanel: onOpenAdminPanel,
          onSignOut: onSignOut,
        );
      },
    );
  }
}

class ProfileCard extends GetView<BancoDeIdeiasController> {
  const ProfileCard({
    super.key,
    required this.usuario,
    required this.onOpenAdminPanel,
    required this.onSignOut,
  });

  final UsuarioAtual usuario;
  final VoidCallback onOpenAdminPanel;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final raw = usuario.raw;
    final nome = raw['nome']?.toString() ?? 'bdi_sem_nome'.tr;
    final email = raw['email']?.toString() ?? '';
    final perfil = _nomeDe(raw['perfil']);
    final curso = _nomeDe(raw['curso']);
    final departamento = _nomeDe(raw['departamento']);

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            AppColors.mediumBlue(alpha: 36),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightBlue(alpha: 46),
                  foregroundColor: Colors.white,
                  child: Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ProfileField(label: 'email'.tr, value: email),
            ProfileField(label: 'bdi_perfil'.tr, value: perfil),
            if (curso.isNotEmpty)
              ProfileField(label: 'curso'.tr, value: curso),
            if (departamento.isNotEmpty)
              ProfileField(label: 'departamento'.tr, value: departamento),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (usuario.isAdministrador)
                  FilledButton.icon(
                    onPressed: onOpenAdminPanel,
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    label: Text('bdi_menu_administrativo'.tr),
                  ),
                OutlinedButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text('sair'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _nomeDe(dynamic value) {
    if (value is Map) {
      return value['nome']?.toString() ?? '';
    }
    return '';
  }
}

class ProfileField extends GetView<BancoDeIdeiasController> {
  const ProfileField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
