import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_notifications_tab.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/ui/widgets/cdc_rooms_tab.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/utils/cdc_help.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';

class CdcPage extends GetView<CdcController> {
  const CdcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: controller.initialTab,
      child: Scaffold(
        backgroundColor: AppColors.darkBlue(),
        appBar: AppBars.build(
          title: 'central_de_comunicacao'.tr,
          actions: [AppBars.helpAction(CdcHelp.url)],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'cdc_aba_salas'.tr),
              Tab(
                child: Obx(() {
                  final unread = controller.unreadCount;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('notificacoes'.tr),
                      if (unread > 0) ...[
                        const SizedBox(width: 6),
                        _UnreadBadge(count: unread),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),
          child: const SafeArea(
            top: false,
            child: TabBarView(
              children: [CdcRoomsTab(), CdcNotificationsTab()],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
