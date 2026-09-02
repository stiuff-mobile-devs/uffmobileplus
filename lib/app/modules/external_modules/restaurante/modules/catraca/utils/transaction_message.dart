import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionMessage extends StatelessWidget {
  final bool isQrCodeValid;
  final bool isTransactionValid;
  final String transactionResultMessage;
  final String transactionUsername;
  final FloatingActionButton actionButton;
  final bool isOfflineMode;

  const TransactionMessage({
    super.key,
    required this.isQrCodeValid,
    required this.isTransactionValid,
    required this.transactionResultMessage,
    required this.transactionUsername,
    required this.actionButton,
    required this.isOfflineMode,
  });

  @override
  Widget build(Object context) {
    return isQrCodeValid
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                transactionUsername != "" ? 'usuario'.tr : "",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Text(
                  transactionUsername,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                isTransactionValid ? Icons.check_circle : Icons.cancel,
                color: isTransactionValid ? Colors.green : Colors.red,
                size: 120.0,
              ),
              isTransactionValid
                  ? Container(
                      margin: EdgeInsets.only(top: 24, left: 30, right: 30),
                      child: isOfflineMode
                          ? Text(
                              'transacao_realizada_modo_offline'.tr,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              'valor_debitado_valor'.trParams({
                                'value': transactionResultMessage,
                              }),
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    )
                  : Container(
                      margin: EdgeInsets.only(top: 24, left: 30, right: 30),
                      child: Text(
                        'nao_foi_possivel_debitar_valor'.trParams({
                          'value': transactionResultMessage,
                        }),
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
              Container(
                width: 192,
                height: 40,
                margin: EdgeInsets.only(top: 50, bottom: 24),
                child: actionButton,
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Text(
                  'codigo_invalido'.tr,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(Icons.cancel, color: Colors.red, size: 120.0),
              Container(
                width: 192,
                height: 40,
                margin: EdgeInsets.only(top: 25, bottom: 24),
                child: actionButton,
              ),
            ],
          );
  }
}
