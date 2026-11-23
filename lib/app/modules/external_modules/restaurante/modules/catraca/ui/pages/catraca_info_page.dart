import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_info_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_app_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_help.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/utils/ui_components/uri_launcher_helper.dart';

/// Informações da catraca: vinculações, conexões, ajuda e versões.
class CatracaInfoPage extends GetView<CatracaInfoController> {
  const CatracaInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: catracaAppBar(
        title: 'catraca_info_titulo'.tr,
        onRefresh: controller.refreshAll,
        showInfo: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _bondsSection(),
              const SizedBox(height: 16),
              _connectionsSection(),
              const SizedBox(height: 16),
              _helpSection(),
              const SizedBox(height: 16),
              _versionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bondsSection() {
    return _Section(
      icon: Icons.link_rounded,
      title: 'catraca_vinculacoes'.tr,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BondTile(
              name: 'IdUFF',
              usage: 'catraca_iduff_uso'.tr,
              active: controller.hasIduffBond.value,
              email: controller.iduffEmail.value,
              loading: controller.isLoading.value,
              onTap: controller.onIduffTap,
            ),
            const Divider(color: Colors.white12, height: 24),
            _BondTile(
              name: 'Google',
              usage: 'catraca_google_uso'.tr,
              active: controller.hasGoogleBond.value,
              email: controller.googleEmail.value,
              loading: controller.isLoading.value,
              onTap: controller.onGoogleTap,
            ),
            if (!controller.isLoading.value &&
                controller.googleEmail.value != null &&
                !controller.isGoogleEmailValid) ...[
              const SizedBox(height: 12),
              _Warning(text: 'catraca_aviso_email_iduff'.tr),
            ],
            if (!controller.isLoading.value &&
                (!controller.hasIduffBond.value ||
                    !controller.hasGoogleBond.value)) ...[
              const SizedBox(height: 12),
              _Warning(text: 'catraca_aviso_duas_vinculacoes'.tr),
            ],
          ],
        ),
      ),
    );
  }

  Widget _connectionsSection() {
    return _Section(
      icon: Icons.wifi_tethering_rounded,
      title: 'conexoes'.tr,
      child: Obx(() {
        final pending = controller.pendingSync.value;
        final lastSync = controller.lastSyncAt.value;
        final String firebaseDetail;
        if (controller.isLoading.value && pending == null) {
          firebaseDetail = 'catraca_verificando'.tr;
        } else if (pending == null) {
          firebaseDetail = 'catraca_pendentes_indisponivel'.tr;
        } else if (pending == 0) {
          firebaseDetail = 'catraca_tudo_sincronizado'.tr;
        } else {
          firebaseDetail = 'catraca_pendentes_sincronizar'.trParams({
            'quantidade': '$pending',
          });
        }
        return Column(
          children: [
            _ConnectionTile(
              label: 'internet'.tr,
              status: controller.internet.value,
            ),
            _ConnectionTile(label: 'SCTM', status: controller.sctm.value),
            _ConnectionTile(label: 'SACI', status: controller.saci.value),
            _ConnectionTile(label: 'UMM', status: controller.umm.value),
            _ConnectionTile(
              label: 'catraca_registro_firebase'.tr,
              status: pending == null ? null : pending == 0,
              loadingWhenNull: controller.isLoading.value,
              detail: [
                firebaseDetail,
                if (lastSync != null)
                  'catraca_ultima_sincronizacao'.trParams({
                    'horario': DateFormat('dd/MM HH:mm').format(lastSync),
                  }),
              ].join('\n'),
              okLabel: 'catraca_estado_registrada'.tr,
              badLabel: 'catraca_estado_pendente'.tr,
            ),
          ],
        );
      }),
    );
  }

  Widget _helpSection() {
    return _Section(
      icon: Icons.help_outline_rounded,
      title: 'ajuda'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'catraca_ajuda_descricao'.tr,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mediumBlue(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text('catraca_abrir_manual'.tr),
              onPressed: () {
                const url = CatracaHelp.manual;
                if (url == null || url.trim().isEmpty) {
                  AppPopups.info('manual_guias_em_construcao'.tr);
                } else {
                  openUrl(url);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _versionSection() {
    return _Section(
      icon: Icons.info_outline_rounded,
      title: 'versao'.tr,
      child: Column(
        children: [
          _InfoRow(
            label: 'catraca_versao_app'.tr,
            value: controller.appVersion.isEmpty ? '-' : controller.appVersion,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'catraca_versao_modulo'.tr,
            value: controller.catracaVersion,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alternativeDarkBlue(),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.lightBlue(), size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BondTile extends StatelessWidget {
  const _BondTile({
    required this.name,
    required this.usage,
    required this.active,
    required this.email,
    required this.loading,
    required this.onTap,
  });

  final String name;
  final String usage;
  final bool active;
  final String? email;
  final bool loading;

  /// Conecta (inativa) ou desconecta (ativa) a vinculação.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: _content()),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _StatusChip(
              status: loading ? null : active,
              okLabel: 'ativo'.tr,
              badLabel: 'inativo'.tr,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          email ?? 'catraca_email_nao_disponivel'.tr,
          style: TextStyle(
            color: email == null ? Colors.white54 : AppColors.lightBlue(),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          usage,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        if (!loading) ...[
          const SizedBox(height: 4),
          Text(
            active ? 'catraca_toque_desconectar'.tr : 'catraca_toque_conectar'.tr,
            style: TextStyle(
              color: AppColors.lightBlue(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({
    required this.label,
    required this.status,
    this.detail,
    this.okLabel,
    this.badLabel,
    this.loadingWhenNull = true,
  });

  final String label;
  final bool? status;
  final String? detail;
  final String? okLabel;
  final String? badLabel;
  final bool loadingWhenNull;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                if (detail != null && detail!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _StatusChip(
            status: status,
            okLabel: okLabel ?? 'catraca_disponivel'.tr,
            badLabel: badLabel ?? 'catraca_indisponivel'.tr,
            showLoading: loadingWhenNull,
          ),
        ],
      ),
    );
  }
}

/// `status == null` mostra "verificando" (ou "indisponível" sem [showLoading]).
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.okLabel,
    required this.badLabel,
    this.showLoading = true,
  });

  final bool? status;
  final String okLabel;
  final String badLabel;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    if (status == null) {
      color = Colors.white54;
      text = showLoading ? 'catraca_verificando'.tr : '-';
    } else if (status!) {
      color = Colors.greenAccent;
      text = okLabel;
    } else {
      color = Colors.orangeAccent;
      text = badLabel;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orangeAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
