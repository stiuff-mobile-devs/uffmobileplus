import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';

/// AppBar padrão de todas as telas da catraca: título da tela, botão de
/// atualizar e botão "?" que abre a tela de informações da catraca.
PreferredSizeWidget catracaAppBar({
  required String title,
  required VoidCallback onRefresh,
  bool showInfo = true,
}) {
  return AppBars.build(
    title: title,
    actions: [
      IconButton(
        tooltip: 'atualizar'.tr,
        icon: const Icon(Icons.refresh_rounded),
        onPressed: onRefresh,
      ),
      if (showInfo)
        IconButton(
          tooltip: 'catraca_info_titulo'.tr,
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: () => Get.toNamed(Routes.CATRACA_INFO),
        ),
    ],
  );
}
