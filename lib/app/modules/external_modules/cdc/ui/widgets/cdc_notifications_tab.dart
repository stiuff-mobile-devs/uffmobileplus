import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/data/models/inbox_notification.dart';
import 'package:uffmobileplus/app/data/services/notification_inbox_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_empty_state.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Aba Notificações: as últimas notificações recebidas neste aparelho.
class CdcNotificationsTab extends GetView<CdcController> {
  const CdcNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: Obx(() {
        final items = controller.notifications.toList();
        final unread = controller.unreadCount;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (items.isEmpty)
              CdcEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'cdc_sem_notificacoes_titulo'.tr,
                message: 'cdc_sem_notificacoes_msg'.tr,
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (unread > 0)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.lightBlue(),
                      ),
                      onPressed: controller.markAllNotificationsRead,
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: Text('cdc_marcar_todas_lidas'.tr),
                    ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    onPressed: controller.clearNotifications,
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: Text('limpar'.tr),
                  ),
                ],
              ),
              for (final n in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NotificationTile(
                    notification: n,
                    onTap: () => controller.openNotification(n),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'cdc_notificacoes_limite'.trParams({
                    'count': '${NotificationInboxService.maxItems}',
                  }),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final InboxNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.read;

    return Material(
      color: Colors.white.withValues(alpha: unread ? 0.1 : 0.05),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue().withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  color: AppColors.lightBlue(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title.isEmpty
                                ? 'central_de_comunicacao'.tr
                                : notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(notification.receivedAt),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final time = DateFormat('HH:mm').format(local);
    if (day == today) return time;
    if (day == today.subtract(const Duration(days: 1))) {
      return '${'ontem'.tr} $time';
    }
    return DateFormat('dd/MM/yy').format(local);
  }
}
