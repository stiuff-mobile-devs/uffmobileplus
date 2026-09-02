import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_validador/controller/carteirinha_validador_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CarteirinhaValidadorResultPage extends GetView<CarteirinhaValidadorController> {
  const CarteirinhaValidadorResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('carteirinha_digital'.tr),
        actions: const [],
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
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'federal'.tr,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'fluminense'.tr,
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
                      
                      // x = 2: Foto do usuário (Fixo)
                      SizedBox(
                        height: 140,
                        child: CachedNetworkImage(
                          imageUrl: controller.validationData.length > 2 
                              ? (controller.validationData[2] ?? "") 
                              : "",
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
                      
                      // Nome (x = 1) e Documento (x = 0) (Fixos)
                      Column(
                        children: [
                          Text(
                            controller.validationData.length > 1 
                                ? (controller.validationData[1] ?? "") 
                                : "",
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            controller.validationData.isNotEmpty &&
                                    controller.validationData[0] != null &&
                                    controller.validationData[0].isNotEmpty
                                ? '${'Documento'.tr}: ${controller.validationData[0]}'
                                : '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // --- APENAS SE x = 3: MAPEIA O 'y' DINAMICAMENTE ---
                        if (controller.validationData.length > 3 && controller.validationData[3] is List)
                        ...(controller.validationData[3] as List).map((itemY) {
                          // Extrai o Map que está na posição z = 0 de cada itemY
                          final Map<String, dynamic> matricula = (itemY is List && itemY.isNotEmpty)
                              ? itemY[0]
                              : (itemY is Map ? itemY : {});

                          if (matricula.isEmpty) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                                  margin: const EdgeInsets.only(top: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          matricula["descricao"] ?? "",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 14, color: Colors.blue[800]),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'matricula'.tr,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          matricula["matricula"] ?? "",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'validade'.tr,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          matricula["data_validade"] ?? "",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'curso'.tr,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        matricula["nome_curso"] ?? "",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.scanQrCode();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              'escanear_nova_carteirinha'.tr,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}