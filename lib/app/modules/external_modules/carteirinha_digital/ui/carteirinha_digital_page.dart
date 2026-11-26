import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/controller/carteirinha_digital_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CarteirinhaDigitalPage extends GetView<CarteirinhaDigitalController> {
  const CarteirinhaDigitalPage({super.key});

  static const double _qrSize = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(
        title: 'carteirinha_digital'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'atualizar'.tr,
            onPressed: controller.refreshCarteirinha,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'carteirinha_info_titulo'.tr,
            onPressed: () => Get.toNamed(Routes.CARTEIRINHA_INFO),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(() {
          if (controller.isBusy.value) {
            return const Center(child: CustomProgressDisplay());
          }
          if (!controller.hasUser) return _noUser();
          return _card(context);
        }),
      ),
    );
  }

  /// Sem dados salvos (abriu pelo login ou por link sem ter entrado).
  Widget _noUser() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge_outlined, size: 72, color: AppColors.lightBlue()),
            const SizedBox(height: 16),
            Text(
              'carteirinha_sem_login_titulo'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'carteirinha_sem_login_msg'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mediumBlue(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.login_rounded),
              label: Text('carteirinha_entrar_iduff'.tr),
              onPressed: controller.loginIduff,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    final matricula = controller.getUserMatricula();
    final validade = controller.getUserValidity();
    final curso = controller.getUserCourse();
    final iduff = controller.getUserIdUFF();

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/carteirinha_digital/images/uff_logo.png",
                height: 30,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final key in ['universidade', 'federal', 'fluminense'])
                    Text(
                      key.tr,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Foto do usuário
        SizedBox(
          height: 140,
          child: CachedNetworkImage(
            imageUrl: controller.getUserPhotoUrl() ?? "",
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(
                  value: downloadProgress.progress,
                  color: Colors.white,
                ),
            errorWidget: (context, url, error) => const Icon(
              Icons.account_circle,
              size: 140,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Nome e IdUFF do usuário
        Column(
          children: [
            Text(
              controller.getUserName() ?? "",
              style: const TextStyle(color: Colors.white),
            ),
            if (iduff.isNotEmpty)
              Text(
                '${'documento'.tr}: $iduff',
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Cartão com informações e QR Code
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          constraints: const BoxConstraints(minHeight: 300),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: Column(
            children: [
              Image.asset(
                "assets/carteirinha_digital/images/brasao_uff.png",
                height: 100,
              ),
              Container(
                margin: const EdgeInsets.only(top: 14),
                alignment: Alignment.centerLeft,
                child: Text(
                  controller.getUserBond(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue(),
                  ),
                ),
              ),
              Divider(height: 14, color: AppColors.mediumBlue()),
              // Campos sem dado não aparecem.
              if (matricula.isNotEmpty || validade.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (matricula.isNotEmpty)
                      _field('matricula'.tr, matricula),
                    if (validade.isNotEmpty) _field('validade'.tr, validade),
                  ],
                ),
              if (curso.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  child: _field('curso'.tr, curso),
                ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(top: 40, bottom: 36),
                width: _qrSize,
                child: qrCodeWidget(controller, context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  /// QR code salvo e, embaixo, o progresso enquanto atualiza no SACI (o QR
  /// não some durante a atualização). Sem QR salvo, aviso e "Tentar novamente".
  Widget qrCodeWidget(
    CarteirinhaDigitalController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final qr = controller.qrCodeData.value;
      final refreshing = controller.isRefreshing.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _qrSize,
            height: _qrSize,
            child: qr.isNotEmpty
                ? QrImageView(data: qr, version: QrVersions.auto)
                : _qrUnavailable(refreshing),
          ),
          const SizedBox(height: 8),
          // Espaço reservado para a tela não pular ao mostrar o progresso.
          SizedBox(
            height: 4,
            child: refreshing
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      color: AppColors.mediumBlue(),
                      backgroundColor: AppColors.lightBlue(),
                    ),
                  )
                : null,
          ),
        ],
      );
    });
  }

  Widget _qrUnavailable(bool refreshing) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_2_rounded,
          size: 64,
          color: AppColors.darkBlue(alpha: 90),
        ),
        const SizedBox(height: 8),
        Text(
          'carteirinha_qr_indisponivel'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue(),
          ),
        ),
        TextButton(
          onPressed: refreshing ? null : controller.refreshCarteirinha,
          child: Text(
            'tentar_novamente'.tr,
            style: TextStyle(color: AppColors.mediumBlue()),
          ),
        ),
      ],
    );
  }
}
