import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ResultadoDetalhadoPage extends GetView<CatracaOnlineController> {
  const ResultadoDetalhadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Obx(() => Text(controller.statusMessage.value)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () {},
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
        () => controller.isDetailResultBusy.value
            ? const Center(child: CustomProgressDisplay())
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (controller
                                .selectedTransaction
                                .value
                                .name
                                ?.isNotEmpty ==
                            true) ...[
                          const Text(
                            "Usuário",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            child: Text(
                              controller.selectedTransaction.value.name ?? '',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 120.0,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Valor Debitado: R\$ ${controller.selectedTransaction.value.value ?? '0,00'}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Feito em: ${controller.selectedTransaction.value.area ?? 'Local não informado'}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Horário: ${controller.selectedTransaction.value.date != null ? DateFormat('dd/MM/yy HH:mm').format(controller.selectedTransaction.value.date!) : 'Data não disponível'}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
