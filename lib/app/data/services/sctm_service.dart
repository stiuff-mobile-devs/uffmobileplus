import 'dart:convert';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';

class SctmService {
  // ===== Restaurante =====

  Future<Map<String, dynamic>> validatePayment(
    String paymentCode,
    String iduff,
    String token,
    String areaId,
  ) async {
    try {
      String idUffUser = "";
      String hash = "";

      if (paymentCode != null && paymentCode.isNotEmpty) {
        const startIdUff = "ididentificacao_iduff=";
        const endIdUff = "&";

        final startIndexIdUff = paymentCode.indexOf(startIdUff);
        if (startIndexIdUff != -1) {
          final endIndexIdUff = paymentCode.indexOf(
            endIdUff,
            startIndexIdUff + startIdUff.length,
          );
          if (endIndexIdUff != -1) {
            idUffUser = paymentCode.substring(
              startIndexIdUff + startIdUff.length,
              endIndexIdUff,
            );
          }
        }

        final startHash = "hash=";
        final startIndexHash = paymentCode.indexOf(startHash);
        if (startIndexHash != -1) {
          hash = paymentCode.substring(startIndexHash + startHash.length);
        }
      }

      var uri = Uri.https(
        Secrets.validarIntencaoPagamentoHost,
        Secrets.validarIntencaoPagamentoPath,
        {
          "iduff_operador": iduff,
          "ididentificacao_iduff": idUffUser,
          "area_debito_operador_id": areaId,
          "hash": hash,
          "token": token,
        },
      );

      http.Response response = await http.post(uri);

      if (response.statusCode == 200) {
        Map responseMap = json.decode(response.body);

        if (responseMap is Map) {
          if (responseMap["status"] == "0") {
            return {
              "valid": true,
              "message":
                  responseMap["content"]?["valor_debitado"] ??
                  "Valor não informado",
              "name": responseMap["content"]?["nome"] ?? "Nome não informado",
            };
          } else {
            String message = "Erro desconhecido";
            String? name;

            if (responseMap.containsKey("content") &&
                responseMap["content"] is Map) {
              message = responseMap["content"]["descricao"] ?? message;
              name = responseMap["content"]["nome"];
            }

            final result = {"valid": false, "message": message};

            if (name != null) {
              result["name"] = name;
            }

            return result;
          }
        }
      }
    } catch (e) {
      // Log do erro se necessário
      print('Erro ao validar pagamento: $e');
    }

    return {"valid": false, "message": "Erro na comunicação com o servidor"};
  }

  Future<List<AreaModel>> getAreas(String iduff, String token) async {
    try {
      var uri = Uri.https(
        Secrets.areasValidationHost,
        Secrets.areasValidationPath,
        {"iduff_operador": iduff, "token": token},
      );

      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final responseMap = json.decode(response.body);

        // Verifica se a estrutura esperada existe
        if (responseMap is Map &&
            responseMap.containsKey("content") &&
            responseMap["content"] is Map &&
            responseMap["content"].containsKey("areas") &&
            responseMap["content"]["areas"] is List) {
          final areasJson = responseMap["content"]["areas"] as List;
          return areasJson
              .where((json) => json is Map)
              .map((json) {
                try {
                  return AreaModel.fromJson(json);
                } catch (e) {
                  // Log ou ignora itens com formato inválido
                  return null;
                }
              })
              .where((area) => area != null)
              .cast<AreaModel>()
              .toList();
        }
      }
    } catch (e) {
      throw Exception('Erro ao buscar áreas: $e');
    }

    return []; // Retorna lista vazia em vez de exception
  }

  Future<List<OperatorTransactionModel>> getOperatorTransactions(
    String iduff,
    String token,
    String areaId,
  ) async {
    try {
      var uri = Uri.https(
        Secrets.transactionsValidationHost,
        Secrets.transactionsValidationPath,
        {
          "iduff_operador": iduff,
          "token": token,
          "area_id": areaId.toString(),
          "minutos": "1440", // Últimas 24 horas = 1440
        },
      );

      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseMap = json.decode(response.body);

        // Verifica se a estrutura esperada existe
        if (responseMap is Map &&
            responseMap.containsKey("content") &&
            responseMap["content"] is Map &&
            responseMap["content"].containsKey("mensagem") &&
            responseMap["content"]["mensagem"] is Map &&
            responseMap["content"]["mensagem"].containsKey("transacoes") &&
            responseMap["content"]["mensagem"]["transacoes"] is List) {
          final transactionsJson =
              responseMap["content"]["mensagem"]["transacoes"] as List;
          return transactionsJson
              .where((json) => json is Map)
              .map((json) {
                try {
                  return OperatorTransactionModel.fromJson(json);
                } catch (e) {
                  // Log ou ignora itens com formato inválido
                  return null;
                }
              })
              .where((transaction) => transaction != null)
              .cast<OperatorTransactionModel>()
              .toList();
        }
      }
    } catch (e) {
      // Log do erro se necessário
      print('Erro ao buscar transações: $e');
    }

    return []; // Retorna lista vazia em vez de exception
  }

  Future<Map<String, dynamic>> getPaymentCode(
    String idUff,
    String accessToken,
  ) async {
    var uri = Uri.https(
      Secrets.generateQrPaymentHost,
      Secrets.generateQrPaymentPath,
      {"iduff_usuario": idUff, "token": accessToken},
    );

    http.Response response = await http.post(uri);
    var responseDecoded = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseDecoded["content"] != null &&
          responseDecoded["content"]["texto_qr_code"] != null &&
          responseDecoded["content"]["validade"] != null) {
        return responseDecoded["content"];
      }
    }

    if (responseDecoded["content"] != null &&
        responseDecoded["content"]["mensagem"] != null) {
      throw Exception(responseDecoded["content"]["mensagem"]);
    } else {
      throw Exception("Ocorreu um erro inesperado.");
    }
  }

  Future<UserBalance> getUserBalance(
    String idUff,
    String accessToken, {
    double? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, String> parameters;
    /* String? googleToken = googleSignInService
        .authenticatedClient
        ?.headers["Authorization"]
        ?.split(" ")[1]; */

    parameters = {
      "iduff_usuario": idUff,
      //if (googleToken != null) "token_google": googleToken,
      "token": accessToken,
    };

    if (period != null) {
      parameters.addAll({"dias": period.toStringAsFixed(0)});
    }
    if (startDate != null) {
      parameters.addAll({"data_inicio": ""});
    }
    if (endDate != null) {
      parameters.addAll({"data_fim": ""});
    }
    var uri = Uri.https(
      Secrets.getUserBalanceHost,
      Secrets.getUserBalancePath,
      parameters,
    );

    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      var responseDecoded = json.decode(response.body);
      if (responseDecoded != null && responseDecoded["content"] != null) {
        UserBalance userBalance = UserBalance()
          ..fromMap(responseDecoded["content"]);
        return userBalance;
      } else {
        throw Exception('Failed to get UserBalance');
      }
    } else {
      throw Exception('Failed to get UserBalance');
    }
  }

  Future<String> getPaymentUrl(
    String value,
    String idUff,
    String accessToken,
  ) async {
    int centsValue = int.parse(value.replaceAll(',', ''));

    Map<String, String> parameters = {
      "iduff_usuario": idUff,
      "token": accessToken,
      "valor": centsValue.toString(),
    };

    var uri = Uri.https(
      Secrets.getPaymentUrlHost,
      Secrets.getPaymentUrlPath,
      parameters,
    );

    http.Response response = await http.post(uri);

    Map<String, dynamic> responseMap = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseMap["content"] != null &&
          responseMap["content"]["url"] != null) {
        return responseMap["content"]["url"];
      } else {
        throw Exception('Failed to get Pending User');
      }
    } else {
      throw Exception('Failed to get Pending User');
    }
  }
}
