import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_info_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/utils/cdc_help.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/utils/ui_components/uri_launcher_helper.dart';

/// Informações da Central de Comunicação: conta Google, manual e versões.
class CdcInfoPage extends GetView<CdcInfoController> {
  const CdcInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(
        title: 'cdc_info_titulo'.tr,
        actions: [
          IconButton(
            tooltip: 'atualizar'.tr,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshAll,
          ),
        ],
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
              _googleSection(),
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

  Widget _googleSection() {
    return _Section(
      icon: Icons.account_circle_outlined,
      title: 'cdc_info_conta_google'.tr,
      child: Obx(() {
        final loading = controller.isLoading.value;
        final active = controller.hasGoogleBond.value;
        final email = controller.googleEmail.value;
        final permission = controller.chatPermission.value;
        final canAskPermission = !loading &&
            active &&
            controller.isUffEmail &&
            permission == false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: loading ? null : controller.onGoogleTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Google',
                                  style: TextStyle(
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
                            email ?? 'cdc_info_sem_conta'.tr,
                            style: TextStyle(
                              color: email == null
                                  ? Colors.white54
                                  : AppColors.lightBlue(),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'cdc_info_google_uso'.tr,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          if (!loading) ...[
                            const SizedBox(height: 4),
                            Text(
                              active
                                  ? 'cdc_info_toque_desconectar'.tr
                                  : 'cdc_info_toque_conectar'.tr,
                              style: TextStyle(
                                color: AppColors.lightBlue(),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'cdc_info_salas_google_chat'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                _StatusChip(
                  status: loading ? null : permission,
                  okLabel: 'cdc_info_permitido'.tr,
                  badLabel: 'cdc_info_sem_permissao'.tr,
                ),
              ],
            ),
            if (canAskPermission) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mediumBlue(),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.onPermissionTap,
                  child: Text('cdc_google_chat_permitir'.tr),
                ),
              ),
            ],
            if (!loading && email != null && !controller.isUffEmail) ...[
              const SizedBox(height: 12),
              _Warning(text: 'cdc_google_chat_outra_conta_msg'.tr),
            ],
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
            'cdc_info_ajuda_descricao'.tr,
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
              label: Text('cdc_info_abrir_manual'.tr),
              onPressed: () {
                const url = CdcHelp.url;
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
            label: 'cdc_info_versao_app'.tr,
            value: controller.appVersion.isEmpty ? '-' : controller.appVersion,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'cdc_info_versao_modulo'.tr,
            value: controller.cdcVersion,
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

/// `status == null` mostra "verificando".
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.okLabel,
    required this.badLabel,
  });

  final bool? status;
  final String okLabel;
  final String badLabel;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    if (status == null) {
      color = Colors.white54;
      text = 'cdc_info_verificando'.tr;
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
