import 'dart:convert';
import 'package:flutter/material.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';

class BusuffApiClient {
  BusuffApiClient();

  /// Última posição conhecida de cada ônibus, por placa. Só devolve as placas
  /// pedidas em [plates]. Retorna `null` se a requisição falhar.
  Future<Map<String, BusuffModel>?> getLastPositions(Set<String> plates) async {
    Uri url = Uri.https('app.uff.br', '/autointelligence/vehicles');
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint(
          'Error -getLastPositions\n status code: ${response.statusCode} \n body response: ${response.body}',
        );
        return null;
      }
      final Map<String, BusuffModel> positions = {};
      for (var element in jsonDecode(response.body)) {
        final plate = element["placa"];
        final gps = element["gps_data"];
        if (plates.contains(plate) && gps is Map<String, dynamic>) {
          positions[plate] = BusuffModel.fromJson(gps);
        }
      }
      return positions;
    } catch (e) {
      debugPrint("error fetching last positions: $e");
    }
    return null;
  }
}
