import 'dart:convert';
import 'package:flutter/material.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';

const baseUrl = 'https://app.uff.br/umm/api/busuff/get_gps';
const CITSMART = 'https://citsmart.uff.br/citsmart/galeriaImagens/1/45/';
const String NITEROI_ROTA1 = '15106.png';
const String NITEROI_ROTA2 = '15107.png';
const String VOLTA_REDONDA = '15109.png';
const String CAMPOS_ROTA1 = '15104.png';
const String CAMPOS_ROTA2 = '15105.png';
const String PADUA = '15108.png';
const String ANGRA = '15103.png';

class BusuffApiClient {
  BusuffApiClient();

  Future<List<BusuffModel>?> getLastPosition() async {
    //https://app.homologacao.uff.br/autointelligence/vehicles.json
    // Uri url = Uri.https('app.uff.br', '/umm/api/busuff/get_gps', {'password': 'LittlePotato', 'id': 'd2bcb6d41f4404e3'});
    List<BusuffModel> busuffs = [];
    Uri url = Uri.https('app.uff.br', '/autointelligence/vehicles');
    try {
      final response = await http.get(url);
      if (response == null) return null;
      if (response.statusCode == 200) {
        dynamic jsonResponse = jsonDecode(response.body);
        for (var element in jsonResponse) {
          if (element["placa"] == "LMB7157" || element["placa"] == "LRN5595") {
            var a = BusuffModel.fromJson(
              element["gps_data"] as Map<String, dynamic>,
            );
            busuffs.add(a);
          }
        }
        return busuffs;
      } else {
        debugPrint(
          'Error -getLastPosition\n status code: ${response.statusCode} \n body response: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("error fetching last position: $e");
    }
    return null;
  }
}
