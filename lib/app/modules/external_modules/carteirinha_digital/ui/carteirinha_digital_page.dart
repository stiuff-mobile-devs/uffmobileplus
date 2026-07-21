import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/controller/carteirinha_digital_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class CarteirinhaDigitalPage extends GetView<CarteirinhaDigitalController> {
  const CarteirinhaDigitalPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('carteirinha_digital'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'atualizar'.tr,
            onPressed: () {
              controller.updateQrCodeData();
            },
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
        () => controller.isBusy.value
            ? const Center(child: CustomProgressDisplay())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'universidade'.tr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'federal'.tr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'fluminense'.tr,
                                  style: TextStyle(
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
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
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
                      // Nome e IDUFF do usuário
                      Column(
                        children: [
                          Text(
                            controller.getUserName() ?? "",

                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            controller.getUserIdUFF().isNotEmpty
                                ? '${'Documento'.tr}: ${controller.getUserIdUFF()}'
                                : '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Cartão com informações e QR Code
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        constraints: const BoxConstraints(minHeight: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/carteirinha_digital/images/brasao_uff.png",
                              height: 100,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 14),
                              child: Row(
                                children: [
                                  Text(
                                    controller.getUserBond(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 14, color: Colors.blue[800]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Visibility(
                                  visible: true,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (controller
                                          .getUserMatricula()
                                          .isNotEmpty) ...[
                                        Text(
                                          'matricula'.tr,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          controller.getUserMatricula(),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: true,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (controller
                                          .getUserValidity()
                                          .isNotEmpty) ...[
                                        Text(
                                          'validade'.tr,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          controller.getUserValidity(),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: true,
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (controller
                                            .getUserCourse()
                                            .isNotEmpty) ...[
                                          Text(
                                            'curso'.tr,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      controller.getUserCourse(),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              margin: const EdgeInsets.only(
                                top: 40,
                                bottom: 36,
                              ),
                              width: 180,
                              height: 180,
                              child: qrCodeWidget(controller, context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Stack qrCodeWidget(
    CarteirinhaDigitalController controller,
    BuildContext context,
  ) {
    return Stack(
      children: [
        Obx(
          () => controller.isQrCodeLoading.value
              ? Center(child: CircularProgressIndicator())
              : controller.qrCodeData.isEmpty
              ? SizedBox.shrink()
              : QrImageView(
                  data: controller.qrCodeData,
                  version: QrVersions.auto,
                ),
        ),
      ],
    );
  }
}
