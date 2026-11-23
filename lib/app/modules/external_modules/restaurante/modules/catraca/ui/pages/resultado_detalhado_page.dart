import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/catraca_transaction_item.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_app_bar.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Detalhe de uma refeição já registrada (lista das últimas 24h ou "ver
/// detalhes" do resultado): status + linha do tempo + dados.
class ResultadoDetalhadoPage extends GetView<CatracaController> {
  const ResultadoDetalhadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: catracaAppBar(
        title: 'catraca_detalhe_transacao'.tr,
        onRefresh: _refresh,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(() {
          final item = controller.selectedItem.value;
          if (item == null) {
            return Center(
              child: Text(
                'nenhuma_transacao_recente'.tr,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          return _Detail(item: item, onSync: _syncAndRefresh);
        }),
      ),
    );
  }

  /// Refresh: conexão + relê o item (o envio ao Firebase pode ter acontecido
  /// pela sincronização automática).
  Future<void> _refresh() async {
    await controller.checkConnection();
    await controller.fetchOperatorTransactions();
    _reloadSelected();
  }

  Future<void> _syncAndRefresh() async {
    await controller.syncNow();
    _reloadSelected();
  }

  void _reloadSelected() {
    final current = controller.selectedItem.value;
    if (current == null) return;
    final updated = controller.recentItems.firstWhereOrNull(
      (i) => i.id == current.id,
    );
    if (updated != null) controller.selectedItem.value = updated;
  }
}

enum _Stage { sctm, offlineSynced, offlinePending }

class _Detail extends StatelessWidget {
  const _Detail({required this.item, required this.onSync});

  final CatracaTransactionItem item;
  final Future<void> Function() onSync;

  _Stage get _stage {
    if (item.source == CatracaTxSource.sctm) return _Stage.sctm;
    return item.isSynced == true ? _Stage.offlineSynced : _Stage.offlinePending;
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stage;
    final Color color;
    final IconData icon;
    final String status;
    switch (stage) {
      case _Stage.sctm:
        color = const Color(0xFF1E8E3E);
        icon = Icons.verified_rounded;
        status = 'catraca_status_validado_sctm'.tr;
      case _Stage.offlineSynced:
        color = const Color(0xFF1565C0);
        icon = Icons.cloud_done_rounded;
        status = 'catraca_status_enviada_firebase'.tr;
      case _Stage.offlinePending:
        color = const Color(0xFFE08A00);
        icon = Icons.cloud_upload_rounded;
        status = 'catraca_aguardando_envio_firebase'.tr;
    }

    final time = item.date != null
        ? DateFormat('HH:mm').format(item.date!)
        : null;
    final isManual = item.method == CatracaTxMethod.manual;
    final hasValue = item.value != null && item.value!.isNotEmpty;

    final steps = <_TimelineStep>[
      _TimelineStep(
        icon: isManual ? Icons.keyboard_rounded : Icons.qr_code_2_rounded,
        title: isManual ? 'catraca_passo_cpf'.tr : 'catraca_passo_qr'.tr,
        trailing: time,
        done: true,
      ),
      if (stage == _Stage.sctm)
        _TimelineStep(
          icon: Icons.verified_rounded,
          title: 'catraca_passo_sctm'.tr,
          subtitle: hasValue
              ? '${'valor_debitado'.tr}: R\$ ${item.value}'
              : null,
          done: true,
        )
      else ...[
        _TimelineStep(
          icon: Icons.phone_android_rounded,
          title: 'catraca_passo_aparelho'.tr,
          trailing: time,
          done: true,
        ),
        _TimelineStep(
          icon: Icons.cloud_rounded,
          title: 'catraca_passo_firebase'.tr,
          subtitle: stage == _Stage.offlineSynced
              ? 'catraca_sincronizado'.tr
              : 'catraca_pendente'.tr,
          done: stage == _Stage.offlineSynced,
        ),
      ],
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 1. Faixa de status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, Color.lerp(color, Colors.black, 0.3)!],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 64),
              const SizedBox(height: 10),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              // 2. Usuário
              Text(
                item.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 3. Percurso
              _Card(
                title: 'catraca_percurso'.tr,
                child: _Timeline(steps: steps, color: color),
              ),
              if (stage == _Stage.offlinePending) ...[
                const SizedBox(height: 12),
                _SyncButton(onSync: onSync),
              ],
              const SizedBox(height: 16),
              // 4. Detalhes
              _Card(
                title: 'catraca_detalhes'.tr,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.place_rounded,
                      label: 'catraca_onde'.tr,
                      value: (item.campus == null || item.campus!.isEmpty)
                          ? 'local_nao_informado'.tr
                          : item.campus!,
                    ),
                    _InfoRow(
                      icon: Icons.badge_rounded,
                      label: 'catraca_quem_realizou'.tr,
                      value: (item.operator == null || item.operator!.isEmpty)
                          ? '-'
                          : item.operator!,
                    ),
                    _InfoRow(
                      icon: isManual
                          ? Icons.keyboard_rounded
                          : Icons.qr_code_2_rounded,
                      label: 'catraca_como'.tr,
                      value: isManual
                          ? 'catraca_metodo_manual'.tr
                          : 'catraca_metodo_qr'.tr,
                    ),
                    _InfoRow(
                      icon: stage == _Stage.sctm
                          ? Icons.cloud_rounded
                          : Icons.cloud_off_rounded,
                      label: 'catraca_modo'.tr,
                      value: stage == _Stage.sctm
                          ? 'catraca_modo_sctm'.tr
                          : 'catraca_modo_offline'.tr,
                    ),
                    if (hasValue)
                      _InfoRow(
                        icon: Icons.payments_rounded,
                        label: 'valor_debitado'.tr,
                        value: 'R\$ ${item.value}',
                      ),
                    _InfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'horario'.tr,
                      value: item.date != null
                          ? DateFormat('dd/MM/yy HH:mm').format(item.date!)
                          : 'data_nao_disponivel'.tr,
                      last: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

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
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.lightBlue(),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.done,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final bool done;
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps, required this.color});

  final List<_TimelineStep> steps;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _buildStep(steps[i], isLast: i == steps.length - 1),
      ],
    );
  }

  Widget _buildStep(_TimelineStep step, {required bool isLast}) {
    final dotColor = step.done ? color : Colors.white38;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.done
                        ? dotColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                  child: Icon(
                    step.done ? step.icon : Icons.hourglass_top_rounded,
                    size: 16,
                    color: dotColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.white24,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: step.done ? Colors.white : Colors.white60,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (step.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        step.subtitle!,
                        style: TextStyle(
                          color: step.done
                              ? Colors.white70
                              : Colors.orangeAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (step.trailing != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                step.trailing!,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _SyncButton extends GetView<CatracaController> {
  const _SyncButton({required this.onSync});

  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final syncing = controller.isSyncing.value;
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE08A00),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: syncing ? null : onSync,
        icon: syncing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sync_rounded),
        label: Text('catraca_sincronizar_agora'.tr),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightBlue(), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
