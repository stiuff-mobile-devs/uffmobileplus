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
            tooltip: 'Atualizar',
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
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Universidade",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Federal",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Fluminense",
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
                      controller.getUserPhotoUrl().length > 0
                          ? SizedBox(
                              height: 140,
                              child: CachedNetworkImage(
                                imageUrl: controller.getUserPhotoUrl(),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          color: Colors.white,
                                        ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Text(
                            controller.getUserName() ?? "-",

                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${'Documento'.tr}: ${controller.getUserIdUFF()}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                                  ),
                                ),
                                Visibility(
                                  visible: true,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                        Text(
                                          'curso'.tr,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                            validateButton(),
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

  GestureDetector validateButton() {
    return GestureDetector(
      onTap: () async {
        if (Platform.isAndroid) {
          await canLaunchUrl(
                Uri(
                  scheme: "https",
                  host: "play.google.com",
                  path: "/store/apps/details",
                  queryParameters: {'id': 'br.uff.validador_carteirinha_uff'},
                ),
              )
              ? await launchUrl(
                  Uri(
                    scheme: "https",
                    host: "play.google.com",
                    path: "/store/apps/details",
                    queryParameters: {'id': 'br.uff.validador_carteirinha_uff'},
                  ),
                )
              : throw 'Could not launch validador url';
        } else if (Platform.isIOS) {
          await canLaunchUrl(
                Uri(
                  scheme: "https",
                  host: "apps.apple.com",
                  path: "/br/app/validador-carteirinha-uff/id1569202162",
                ),
              )
              ? await launchUrl(
                  Uri(
                    scheme: "https",
                    host: "apps.apple.com",
                    path: "/br/app/validador-carteirinha-uff/id1569202162",
                  ),
                )
              : throw 'Could not launch validador url';
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(top: 20, bottom: 16),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 13.0, color: Colors.black),
            children: [
              TextSpan(text: "validador_instrucao".tr),
              TextSpan(
                text: " Validador Carteirinha UFF",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
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
              : QrImageView(
                  data: controller.qrCodeData,
                  version: QrVersions.auto,
                ),
        ),

        AnimatedOpacity(
          opacity: controller.isExpired.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          child: Visibility(
            visible: controller.isExpired.value,
            child: Align(
              alignment: Alignment.center,
              child: IconButton(
                iconSize: 40,
                onPressed: () => controller.updateQrCodeData(),
                icon: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0.4, 0.4),
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Icon(Icons.refresh, color: Colors.blue[800]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
