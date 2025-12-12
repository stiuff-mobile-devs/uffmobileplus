import 'dart:convert';

import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:http/http.dart' as http;

class PayRestaurantProvider {
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
}
