import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ValidarManualmentePage extends GetView<CatracaOnlineController> {
  final TextEditingController cpfController = TextEditingController();
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
        () => controller.isManualValidationBusy.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: cpfController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            hintText: '000.000.000-00',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final cpf = cpfController.text.trim();
                            final isValid = await controller.cpfIsValid(cpf);
                            if (isValid) {
                              // Lógica para CPF válido
                              await controller.saveCpfValidationTransaction(cpf);
                            } else {
                              // Lógica para CPF inválido
                              Get.snackbar(
                             'O CPF informado é inválido.',
                             'Por favor, verifique e tente novamente.',
                             backgroundColor: Colors.redAccent,
                             colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                            }
                            
                          },
                          child: const Text('Validar'),
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
