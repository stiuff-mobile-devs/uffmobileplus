import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/controller/pay_restaurant_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/card_details.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class PayRestaurantPage extends GetView<PayRestaurantController> {
  const PayRestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('Pagar Restaurante'.tr),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'atualizar'.tr,
            onPressed: () {
              controller.onInit();
            },
          ),
        ],
      ),

      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: Builder(
                  builder: (context) {
                    final balance = double.parse(
                      controller.currentBalance.value.toString().replaceAll(
                        ',',
                        '.',
                      ),
                    );
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: IdCard(
                              userImageUrl: controller.userImageUrl,
                              username: controller.userName,
                              iduff: controller.userIdUFF,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'saldo_atual'.tr,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.blue[100],
                              ),
                            ),
                            Text(
                              "R\$ ${controller.currentBalance.value}",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: balance < 0.70
                                    ? Colors.red
                                    : Colors.blue[100],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (balance < 0.70)
                          Text(
                            'recarregue_para_usar_bandejao'.tr,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.red[300],
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Text(
                            'refeicoes_disponiveis'.trParams(
                                {'count': '${(balance / 0.70).floor()}'}),
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.green[300],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        SizedBox(
                          width: 260,
                          child: Container(
                            margin: EdgeInsets.only(top: 20, bottom: 24),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'valor_nao_debitado_se_nao_utilizado'
                                    .tr,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.blue[200],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff052750),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 18,
                            ),
                          ),
                          onPressed: () {
                            controller.goToPaymentTicket();
                          },
                          child: Text(
                            'gerar_codigo'.tr,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 220,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 20),
                          child: TextButton(
                            onPressed: () {
                              controller.goToPaymentHelpScreen();
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.help, color: Colors.white, size: 24),
                                Container(
                                  margin: EdgeInsets.only(right: 14),
                                  child: Text(
                                    'como_utilizar_codigo'.tr,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
