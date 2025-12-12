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
        title: Text("Pagar Restaurante"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),

      body: Obx(
        () => controller.isPaymentProcessing.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: Column(
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
                          "Saldo Atual: ",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.blue[100],
                          ),
                        ),
                        Text(
                          "R\$ ${controller.currentBalance}",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.blue[100],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 260,
                      child: Container(
                        margin: EdgeInsets.only(top: 20, bottom: 24),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text:
                                'O valor não será debitado caso o código não seja utilizado.',
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
                        "Gerar Código",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
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
                                " Como utilizar o código",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
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
