import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:http/http.dart' as http;

class CdcService {
  /// Registra o device token na CDC.
  /// Funciona para ambos os tipos de login (Google e Keycloak/IdUFF).
  /// A API usa o header `Authorization: Bearer <token>` para autenticação.
  /// Retorna `true` se o registro foi bem-sucedido, `false` caso contrário.
  Future<bool> registerToken(
    String authToken,
    String deviceToken,
    String platform,
  ) async {
    try {
      var uri = Uri.https(
        Secrets.registerTokenCdcHost,
        Secrets.registerTokenCdcPath,
      );

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({"token": deviceToken, "platform": platform}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Sucesso ao registrar token CDC: ${response.body}");
        return true;
      } else {
        debugPrint(
          "Erro ao registrar token CDC: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Erro ao conectar com servidor CDC: $e");
      return false;
    }
  }
}
