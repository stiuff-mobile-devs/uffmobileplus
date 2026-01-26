import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/config/secrets.dart';

class SosProvider {
  Future<bool> postSosAlert(
    String? nome,
    String matricula,
    double lat,
    double lng,
  ) async {
    //final Uri url = Uri.parse(Secrets.sosApiUrl);
    final Uri url = Uri.parse('https://sos.uffmobile.com.br/api/alerta');

    final body = jsonEncode({
      "nome": nome,
      "matricula": matricula,
      "latitude": lat,
      "longitude": lng,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Type': 'PluginSOS'},
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
