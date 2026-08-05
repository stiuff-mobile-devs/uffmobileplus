import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/controller/pay_restaurant_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/card_details.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/time_helper.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class PayTicketPage extends GetView<PayRestaurantController> {
  const PayTicketPage({super.key});

  static const double _qrSize = 230;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text("Ticket de Pagamento"),
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IdCard(
                          userImageUrl: controller.userImageUrl,
                          username: controller.userName,
                          iduff: controller.userIdUFF,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          "Aponte o código para a leitora",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.blue[100],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: _qrSize,
                          width: _qrSize,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: QrImageView(
                            data: controller.paymentCode["texto_qr_code"],
                            version: QrVersions.auto,
                            size: _qrSize,
                          ),
                        ),
                        const Spacer(),
                        Obx(
                          () => controller.isExpired.value
                              ? Text(
                                  'Código expirado',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.blue[100],
                                  ),
                                )
                              : RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: 'Expira em ',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.blue[100],
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: TimeHelper
                                            .expirationRemainingTime(
                                          controller.remainingTime.value,
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => Visibility(
                            visible: controller.isExpired.value,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: GestureDetector(
                              onTap: () {
                                controller.refresh();
                              },
                              child: Icon(
                                Icons.refresh,
                                color: Colors.blue[100],
                                size: 38.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}