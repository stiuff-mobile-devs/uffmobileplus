import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/controller/busuff_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/widgets.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class BusuffPage extends GetView<BusuffController> {
  const BusuffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (tabContext) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 8,
            foregroundColor: Colors.white,
            title: const Text('Busuff'),
            actions: [
              const Tooltip(
                message: "O Busuff ainda está em beta",
                child: Text("Beta"),
              ),
              IconButton(
                onPressed: () {
                  controller.goDocBus();
                },
                icon: const Icon(Icons.question_mark),
              ),
            ],
            bottom: TabBar(
              labelPadding: EdgeInsets.all(14),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: <Widget>[Text('routes'.tr), Text('maps'.tr)],
              onTap: (i) => controller.onTabTap(
                i,
                DefaultTabController.of(tabContext),
                tabContext,
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppColors.appBarTopGradient(),
              ),
            ),
          ),
          body: Obx(
            () => controller.isLoading.value
                ? Center(child: CustomProgressDisplay())
                : GetBuilder<BusuffController>(
                    builder: (_) => TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        busuffStaticWidget(controller),
                        busuffMapWidget(controller),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
