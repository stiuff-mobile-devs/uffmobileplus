import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/connections/controller/connections_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ConnectionsPage extends GetView<ConnectionsController> {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('conexoes'.tr),
        actions: [
          IconButton(
            onPressed: controller.refreshConnectionsForTest,
            icon: Icon(Icons.refresh),
            color: Colors.white70,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),

      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),
          child: controller.isLoading.value
              ? const Center(child: CustomProgressDisplay())
              : _buildConnectionsContent(context),
        ),
      ),
    );
  }

  Widget _buildConnectionsContent(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _buildConnectionsHeader(),
          const SizedBox(height: 16),
          _buildInternetConnectionCard(context),
          const SizedBox(height: 12),
          _buildSaciUmmConnectionCard(context),
          const SizedBox(height: 12),
          _buildSctmConnectionCard(context),
        ],
      ),
    );
  }

  Widget _buildConnectionsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        'conexoes_descricao'.tr,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInternetConnectionCard(BuildContext context) {
    return _buildSimpleConnectionCard(
      context: context,
      connection: controller.isInternetConnected,
      title: 'internet'.tr,
      description: 'internet_descricao'.tr,
      connectedColor: Colors.cyan.shade300,
      disconnectedColor: Colors.redAccent,
      connectedIcon: Icons.wifi_rounded,
      disconnectedIcon: Icons.wifi_off_rounded,
      connectedLabel: 'ATIVO',
      disconnectedLabel: 'DESCONECTADO',
      connectedDescription: 'A internet está disponível no momento.',
      disconnectedDescription: 'A internet está indisponível no momento.',
    );
  }

  Widget _buildSaciUmmConnectionCard(BuildContext context) {
    return Obx(() {
      final saciUmmStatus = controller.isSaciUmmConnected.value;
      final statusInfo = _getSaciUmmStatusInfo(saciUmmStatus);

      return _buildConnectionCard(
        title: 'STI',
        description: 'Conexão aos sitemas da STI',
        icon: statusInfo.icon,
        accentColor: statusInfo.color,
        isConnected: saciUmmStatus == 2,
        statusLabel: statusInfo.label,
        onTap: () => _showStatusSheet(
          context: context,
          title: 'STI',
          statusInfo: statusInfo,
          detailRows: const [
            (label: 'Carteirinha e STI online', color: Color(0xFF31D07E)),
            (label: 'Somente STI online', color: Color(0xFFF2C94C)),
            (label: 'Somente Carteirinha online', color: Color(0xFFFF9F43)),
            (label: 'Ambos offline', color: Colors.redAccent),
          ],
        ),
      );
    });
  }

  Widget _buildSctmConnectionCard(BuildContext context) {
    return _buildSimpleConnectionCard(
      context: context,
      connection: controller.isSctmConnected,
      title: 'SCTM',
      description: 'Conexão aos sistemas do R.U',
      connectedColor: Colors.green.shade400,
      disconnectedColor: Colors.redAccent,
      connectedIcon: Icons.hub_rounded,
      disconnectedIcon: Icons.hub_rounded,
      connectedLabel: 'ATIVO',
      disconnectedLabel: 'DESCONECTADO',
      connectedDescription: 'O SCTM está disponível no momento.',
      disconnectedDescription: 'O SCTM está indisponível no momento.',
    );
  }

  Widget _buildSimpleConnectionCard({
    required BuildContext context,
    required RxBool connection,
    required String title,
    required String description,
    required Color connectedColor,
    required Color disconnectedColor,
    required IconData connectedIcon,
    required IconData disconnectedIcon,
    required String connectedLabel,
    required String disconnectedLabel,
    required String connectedDescription,
    required String disconnectedDescription,
  }) {
    return Obx(() {
      final isConnected = connection.value;
      final statusInfo = isConnected
          ? (
              color: connectedColor,
              label: connectedLabel,
              description: connectedDescription,
              icon: connectedIcon,
            )
          : (
              color: disconnectedColor,
              label: disconnectedLabel,
              description: disconnectedDescription,
              icon: disconnectedIcon,
            );

      return _buildConnectionCard(
        title: title,
        description: description,
        icon: statusInfo.icon,
        accentColor: statusInfo.color,
        isConnected: isConnected,
        statusLabel: statusInfo.label,
        onTap: () => _showStatusSheet(
          context: context,
          title: title,
          statusInfo: statusInfo,
          detailRows: [
            (label: statusInfo.description, color: statusInfo.color),
          ],
        ),
      );
    });
  }

  Widget _buildConnectionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isConnected,
    String? statusLabel,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.65),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(
                    isConnected: isConnected,
                    accentColor: accentColor,
                    customLabel: statusLabel,
                  ),
                  if (onTap != null) ...[
                    const SizedBox(height: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required bool isConnected,
    required Color accentColor,
    String? customLabel,
  }) {
    final Color badgeColor = isConnected ? accentColor : Colors.redAccent;
    final String label = customLabel ?? (isConnected ? 'ativo'.tr : 'falha'.tr);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badgeColor.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  ({Color color, String label, String description, IconData icon})
  _getSaciUmmStatusInfo(int status) {
    switch (status) {
      case 2:
        return (
          color: const Color(0xFF31D07E),
          label: 'ATIVO',
          description: 'SACI e UMM estão online.',
          icon: Icons.verified_rounded,
        );
      case 3:
        return (
          color: const Color(0xFFF2C94C),
          label: 'STI ONLINE',
          description: 'Somente a STI está online. A carteirinha está indisponível.',
          icon: Icons.warning_amber_rounded,
        );
      case 4:
        return (
          color: const Color(0xFFFF9F43),
          label: 'Carteirinha ONLINE',
          description: 'Somente a carteirinha está online. A STI está indisponível.',
          icon: Icons.report_problem_rounded,
        );
      default:
        return (
          color: Colors.redAccent,
          label: 'DESCONECTADO',
          description: 'Carteirinha e STI estão offline no momento.',
          icon: Icons.cloud_off_rounded,
        );
    }
  }

  Future<void> _showStatusSheet({
    required BuildContext context,
    required String title,
    required ({Color color, String label, String description, IconData icon}) statusInfo,
    required List<({String label, Color color})> detailRows,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1B33),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: statusInfo.color.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(statusInfo.icon, color: statusInfo.color, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status de $title',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusInfo.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  statusInfo.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                for (final row in detailRows) ...[
                  _buildStatusDetailRow(row.label, row.color),
                  if (row != detailRows.last) const SizedBox(height: 10),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusInfo.color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusDetailRow(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
