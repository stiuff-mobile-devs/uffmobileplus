import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class UmmService {
  Future<bool> getStatus() async {
    try {
      var uri = Uri.https(Secrets.getStatusUMMHost, Secrets.getStatusUMMPath);

      http.Response response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5));
      debugPrint("Resposta do UMM: ${response.statusCode}");

      return response.statusCode == 200;
    } on TimeoutException catch (_) {
      // Erro específico de demora na resposta
      debugPrint("Erro: O sistema UMM demorou demais para responder.");
      return false;
    } on SocketException catch (_) {
      // Erro específico de rede (sem internet ou DNS falhou)
      debugPrint("Erro: Sem conexão de rede para alcançar o UMM.");
      return false;
    } catch (e) {
      // Qualquer outro erro inesperado
      debugPrint("Erro desconhecido ao checar status: $e");
      return false;
    }
  }

   Future<List<GdiGroups>> getGdiGroups(String iduff, String token) async {
    final path = '${Secrets.gdiGroupsPath}/$iduff${Secrets.gdiGroupsQuery}';
    var uri = Uri.https(Secrets.gdiGroupsHost, path);
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((group) => GdiGroups.fromJson(group)).toList();
      }
    } catch (e) {
      debugPrint("Erro ao buscar grupos GDI: $e");
      return [];
    }
    return [];
  }
}
