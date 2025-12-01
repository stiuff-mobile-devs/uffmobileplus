import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/utils/transaction_list.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ValidarPagamentoPage extends GetView<CatracaOnlineController> {
  const ValidarPagamentoPage({super.key});

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
            onPressed: () {
              controller.fetchOperatorTransactions();
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
        () => controller.isTransactionBusy.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.selectedArea.value.nome ??
                                    'Área não selecionada',
                                style: TextStyle(
                                  color: Colors.blue[100],
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                constraints: BoxConstraints(maxWidth: 40),
                                iconSize: 24,
                                icon: Icon(
                                  Icons.change_circle,
                                  color: Colors.blue[100],
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.darkBlue(),
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            margin: EdgeInsets.only(
                              left: 26,
                              right: 26,
                              top: 10,
                              bottom: 160,
                            ),
                            child:
                                controller.operatorTransactions.isEmpty &&
                                    controller
                                        .operatorTransactionsOffline
                                        .isEmpty
                                ? Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    height: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                    child: Text(
                                      "Nenhuma transação recente.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                : TransactionList(
                                    controller.operatorTransactions,
                                    controller.operatorTransactionsOffline,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 134, right: 26),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.manualValidation();
                              },
                              child: Text(
                                "Liberar Manualmente ",
                                style: TextStyle(color: Colors.blue[100]),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Colors.blue[100],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 56),
                        child: FloatingActionButton.extended(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: const Color(0xff052750),
                          icon: const Icon(
                            Icons.crop_free,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Ler QR Code",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          onPressed: () {
                            controller.readCode();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
