import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/catraca_transaction_item.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/area_image.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_app_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_bottom_actions.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_status_badge.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ValidarPagamentoPage extends GetView<CatracaController> {
  const ValidarPagamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: catracaAppBar(
        title: 'catraca_validar_pagamento'.tr,
        onRefresh: controller.refreshTransactions,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(
          () => controller.isTransactionBusy.value
              ? const Center(child: CustomProgressDisplay())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _CampusHeader(),
                    const _ListTitle(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.fetchOperatorTransactions,
                        child: controller.recentItems.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      'nenhuma_transacao_recente'.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  16,
                                ),
                                itemCount: controller.recentItems.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, index) {
                                  final item = controller.recentItems[index];
                                  return _TransactionTile(
                                    item: item,
                                    onTap: () => controller.goToDetalhado(item),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const CatracaBottomActions(),
    );
  }
}

/// Campus atual + trocar + estado da sincronização.
class _CampusHeader extends GetView<CatracaController> {
  const _CampusHeader();

  @override
  Widget build(BuildContext context) {
    final area = controller.selectedArea.value;
    final isFallback = areaImagePath(area) == areaFallbackImage;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.alternativeDarkBlue(),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFallback ? Colors.white : null,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: EdgeInsets.all(isFallback ? 6 : 0),
                    child: Image.asset(
                      areaImagePath(area),
                      fit: isFallback ? BoxFit.contain : BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.lightBlue(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.nome ?? 'area_nao_selecionada'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const CatracaStatusBadge(),
                  ],
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.lightBlue(),
                ),
                onPressed: Get.back,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text('catraca_trocar'.tr),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _SyncStatus(),
        ],
      ),
    );
  }
}

class _SyncStatus extends GetView<CatracaController> {
  const _SyncStatus();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pending = controller.pendingSyncCount.value;
      final syncing = controller.isSyncing.value;
      final ok = pending == 0;
      final color = ok ? Colors.greenAccent : Colors.orangeAccent;
      return Row(
        children: [
          Icon(
            ok ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok
                  ? 'catraca_tudo_sincronizado_curto'.tr
                  : 'catraca_n_pendentes'.trParams({'quantidade': '$pending'}),
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
          if (!ok)
            SizedBox(
              height: 32,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  side: const BorderSide(color: Colors.orangeAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: syncing ? null : controller.syncNow,
                icon: syncing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orangeAccent,
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 18),
                label: Text('catraca_sincronizar'.tr),
              ),
            ),
        ],
      );
    });
  }
}

class _ListTitle extends GetView<CatracaController> {
  const _ListTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Text(
            'catraca_ultimas_24h'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.mediumBlue(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(
              () => Text(
                '${controller.recentItems.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item, required this.onTap});

  final CatracaTransactionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSctm = item.source == CatracaTxSource.sctm;
    // Debitada (SCTM) · Pendente (no aparelho) · Registrada (Firebase)
    final Color sourceColor;
    final String stateLabel;
    if (isSctm) {
      sourceColor = Colors.greenAccent;
      stateLabel = 'catraca_estado_debitada'.tr;
    } else if (item.isSynced == true) {
      sourceColor = Colors.lightBlueAccent;
      stateLabel = 'catraca_estado_registrada'.tr;
    } else {
      sourceColor = Colors.orangeAccent;
      stateLabel = 'catraca_estado_pendente'.tr;
    }
    final time = item.date != null
        ? DateFormat('HH:mm').format(item.date!)
        : '--:--';
    final subtitle = [
      time,
      if (item.campus != null && item.campus!.isNotEmpty) item.campus!,
    ].join(' · ');

    return Material(
      color: AppColors.alternativeDarkBlue(),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.mediumBlue().withValues(alpha: 0.3),
                child: Icon(
                  item.method == CatracaTxMethod.manual
                      ? Icons.keyboard_rounded
                      : Icons.qr_code_2_rounded,
                  color: AppColors.lightBlue(),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sourceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sourceColor.withValues(alpha: 0.7)),
                ),
                child: Text(
                  stateLabel,
                  style: TextStyle(
                    color: sourceColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
