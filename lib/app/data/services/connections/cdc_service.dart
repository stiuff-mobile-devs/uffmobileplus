import 'dart:convert'; // Import necessário para jsonEncode
import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:http/http.dart' as http;

class CdcService {
  // Ajustei os parâmetros para corresponder ao que seu backend espera
  Future<void> registerToken(String firebaseIdToken, String devicetoken, String platform) async {
    try {
      var uri = Uri.https(Secrets.registerTokenCdcHost, Secrets.registerTokenCdcPath);
      
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $firebaseIdToken', // O token de autenticação
        },
        body: jsonEncode({
          "token": devicetoken,
          "platform": platform,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Sucesso ao registrar token: ${response.body}");
      } else {
        debugPrint("Erro ao registrar token: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Erro ao conectar com servidor: $e");
    }
  }
}