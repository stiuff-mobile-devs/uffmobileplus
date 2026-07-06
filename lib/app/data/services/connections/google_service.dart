import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:http/http.dart' as http;

class GoogleService {
  Future<GdiGroupsGoogle> getGdiGroupsGoogle(String token, String email) async {
    try {
      DateTime now = DateTime.now();
      Uri url = Uri.https(
        Secrets.gdiGroupsGoogleHost,
        Secrets.gdiGroupsGooglePath,
        {'email': email},
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<GdiGroups> gdiGroups = (jsonData['groups'].toList() as List)
            .map((group) => GdiGroups.fromJson(group))
            .toList();
        GdiGroupsGoogle gdiGroupsGoogle = GdiGroupsGoogle(now, gdiGroups);
        debugPrint(
          "Grupos GDI obtidos com sucesso: ${gdiGroupsGoogle.gdiGroups}",
        );
        return gdiGroupsGoogle;
      } else {
        throw Exception('Falha ao buscar grupos GDI: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erro ao obter grupos GDI: $e");
      return GdiGroupsGoogle(DateTime.now(), []);
    }
  }

  Future<void> registerToken(
    String firebaseIdToken,
    String devicetoken,
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
          'Authorization': 'Bearer $firebaseIdToken', // O token de autenticação
        },
        body: jsonEncode({"token": devicetoken, "platform": platform}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Sucesso ao registrar token: ${response.body}");
      } else {
        debugPrint(
          "Erro ao registrar token: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Erro ao conectar com servidor: $e");
    }
  }
}
