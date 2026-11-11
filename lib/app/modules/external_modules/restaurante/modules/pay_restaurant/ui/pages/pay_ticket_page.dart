import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/controller/pay_restaurant_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/card_details.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/time_helper.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

/// Ticket com o QR de pagamento. Cartão compacto em cima e, abaixo, o bloco
/// texto + QR + validade centralizado. O QR é o maior possível até [_maxQr]
/// (tamanho bom para a leitora), sem rolagem e sem nada por cima dele.
class PayTicketPage extends GetView<PayRestaurantController> {
  const PayTicketPage({super.key});

  // Alturas fixas reservadas (textos em uma linha, escalados se preciso).
  static const double _hPadding = 16;
  static const double _instructionHeight = 30;
  static const double _expiryHeight = 26;
  static const double _refreshHeight = 44;
  static const double _gap = 12;
  static const double _minQr = 140;

  /// Teto do QR. A leitora da catraca tem janela e foco fixos: um QR do
  /// tamanho da tela não cabe inteiro nela de perto. dp é independente da
  /// densidade da tela, então 240 dp ≈ 3,8 cm em qualquer celular (antes da
  /// reforma o QR era fixo em 230). Ajuste só este número se precisar.
  static const double _maxQr = 240;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(title: 'ticket_de_pagamento'.tr),
      body: Obx(
        () => controller.isPaymentProcessing.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: SafeArea(child: LayoutBuilder(builder: _layout)),
              ),
      ),
    );
  }

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    // Cartão compacto: ~18% da altura, sem passar da largura disponível.
    final maxCardByWidth =
        (width - 2 * _hPadding) * IdCard.baseHeight / IdCard.baseWidth;
    final cardHeight = math.min(
      (height * 0.18).clamp(72.0, 130.0),
      maxCardByWidth,
    );

    final reserved =
        cardHeight +
        _instructionHeight +
        _expiryHeight +
        _refreshHeight +
        _gap * 5;
    final qrSize = math
        .min(width - 2 * _hPadding, height - reserved)
        .clamp(_minQr, _maxQr)
        .toDouble();

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hPadding),
      child: Column(
        children: [
          const SizedBox(height: _gap),
          IdCard(
            userImageUrl: controller.userImageUrl,
            username: controller.userName,
            iduff: controller.userIdUFF,
            height: cardHeight,
          ),
          // Texto, QR e validade formam um bloco só, centralizado abaixo do
          // cartão: o espaço livre fica acima e abaixo do bloco, nunca entre
          // o texto e o QR.
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: _instructionHeight,
                    child: _OneLine(
                      'aponte_codigo_leitora'.tr,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue[100],
                      ),
                    ),
                  ),
                  const SizedBox(height: _gap),
                  Container(
                    width: qrSize,
                    height: qrSize,
                    padding: EdgeInsets.all(qrSize * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: QrImageView(
                      data: controller.paymentCode["texto_qr_code"],
                      version: QrVersions.auto,
                    ),
                  ),
                  const SizedBox(height: _gap),
                  SizedBox(
                    height: _expiryHeight,
                    child: Obx(
                      () => controller.isExpired.value
                          ? _OneLine(
                              'codigo_expirado'.tr,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.blue[100],
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text.rich(
                                TextSpan(
                                  text: 'expira_em'.tr,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.blue[100],
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: TimeHelper.expirationRemainingTime(
                                        controller.remainingTime.value,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: _refreshHeight,
                    child: Obx(
                      () => Visibility(
                        visible: controller.isExpired.value,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: IconButton(
                          onPressed: controller.refresh,
                          tooltip: 'atualizar'.tr,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.blue[100],
                            size: 36.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: _gap),
        ],
      ),
    );

    // Em telas muito baixas o QR mínimo pode não caber: aí rola, sem estourar.
    if (height - reserved >= _minQr) return content;
    return SingleChildScrollView(
      child: SizedBox(height: reserved + _minQr, child: content),
    );
  }
}

/// Texto de uma linha que encolhe para caber (fonte grande do sistema).
class _OneLine extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _OneLine(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, textAlign: TextAlign.center, style: style),
    );
  }
}
