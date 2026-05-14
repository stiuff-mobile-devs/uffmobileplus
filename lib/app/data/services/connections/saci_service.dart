import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';


class SaciService {
Future<bool> getStatus() async {
    try {
      var uri = Uri.https(Secrets.getStatusSACIHost, Secrets.getStatusSACIPath);

      http.Response response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5));
      debugPrint("Resposta do SACI: ${response.statusCode}");
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

Future<List<dynamic>> getSaciData(String? token, String? iduffUsuario, AuthIduffService auth) async {
   try{
    var uri = Uri.https(
      Secrets.carteirinhaValidationHost,
      Secrets.carteirinhaValidationPath,
      {"iduff_usuario": iduffUsuario, "token": token ?? ""},
    );

    http.Response response = await auth.client!.post(uri);
    var responseDecoded = json.decode(response.body);
    
    if (response.statusCode == 200) {
      if (responseDecoded["content"] != null) {
        final data = json.decode(response.body);
        final textoQrCode = data['content']['texto_qr_code'].toString();
        final dataValidade =
            data['content']['dados_usuario']['vinculacoes'][0]['data_validade'];
        return [textoQrCode, dataValidade];
      }
    }
   }
    catch(e){
      debugPrint("Erro ao obter dados do SACI: $e");
      return [];
    }
    return [];
  }
}