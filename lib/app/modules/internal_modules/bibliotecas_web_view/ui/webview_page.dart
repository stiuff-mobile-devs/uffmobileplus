import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/internal_modules/web_view/controller/webview_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  const WebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WebViewPageController>(
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await onExit(controller)) Get.back();
          },
          child: Scaffold(
            backgroundColor: AppColors.darkBlue(),
            appBar: AppBars.build(
              title: controller.title,
              leading: IconButton(
                tooltip: 'voltar'.tr,
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () async {
                  if (await onExit(controller)) Get.back();
                },
              ),
              actions: [
                if (controller.interrogation)
                  IconButton(
                    tooltip: 'ajuda'.tr,
                    icon: const Icon(Icons.help_outline_rounded),
                    onPressed: controller.goDocPage,
                  ),
                IconButton(
                  tooltip: 'fechar'.tr,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            body: WebViewWidget(controller: controller.wvc),
          ),
        );
      },
    );
  }

  /// Volta no histórico da WebView. Retorna true quando não há mais histórico
  /// (a tela pode ser fechada).
  Future<bool> onExit(WebViewPageController controller) async {
    if (await controller.wvc.canGoBack()) {
      controller.wvc.goBack();
      return Future.value(false);
    }
    return Future.value(true);
  }
}
