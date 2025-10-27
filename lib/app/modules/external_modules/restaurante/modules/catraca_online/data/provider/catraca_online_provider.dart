import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction_offline.dart';

class CatracaOnlineProvider {
  final String _collectionPath = "operator_transactions";
  final String _collectionPathFirebase = "meals";
  final String _userKey = "current_user";
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app('catracaoffline'),
  );

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
      // Log do erro se necessário
      print('Erro ao buscar áreas: $e');
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

  Future<String> saveOperatorTransactionsOffline(
    OperatorTransactionOffline operatorTransactionOffline,
  ) async {
    try {
      var box = await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      await box.put(operatorTransactionOffline.id, operatorTransactionOffline);
      return "success";
    } catch (e) {
      return "Erro ao salvar dados do usuário no Hive: $e";
    }
  }

  Future<List<OperatorTransactionOffline>>
  getOperatorTransactionsOffline() async {
    try {
      var box = await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> saveOperatorTransactionToFirebase(
    OperatorTransactionOffline operatorTransactionOffline,
  ) async {
    try {
      final Map<String, dynamic> data = operatorTransactionOffline.toJson();

      final docRef = _firestore
          .collection(_collectionPathFirebase)
          .doc(operatorTransactionOffline.id);

      await docRef.set(data, SetOptions(merge: true));
      return "success";
    } catch (e) {
      return "Erro ao salvar no Firebase: $e";
    }
  }
}
