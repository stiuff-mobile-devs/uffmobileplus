import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_model.dart';

class TranscriptProvider {
  final ExternalModulesServices _transcriptService =
      Get.find<ExternalModulesServices>();

  Future<TranscriptModel?> getTranscript(bool isRefresh) async {
    final box = await Hive.openBox<TranscriptModel>('transcript');
    String matricula = _transcriptService.getUserMatricula();
    TranscriptModel? transcript;

    if (!isRefresh) {
      transcript = box.get(matricula);
    }

    if (transcript == null) {
      transcript = await _getTranscriptData();
      if (transcript == null) return null;
      box.put(matricula, transcript);
    }
    return transcript;
  }

  Future<TranscriptModel?> _getTranscriptData() async {
    final bondId = _transcriptService.getUserBondId();
    final accessToken = await _transcriptService.getAccessToken();

    // Monta a URL
    Uri url = Uri(
      host: 'app.uff.br',
      path: '/umm/v2/umplus/get_history',
      scheme: 'https',
      queryParameters: {'vinculo': bondId},
    );

    // Pede o histórico (transcript) do aluno
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return TranscriptModel.fromJson(jsonResponse);
      } else {
        debugPrint(
          "Transcript API failed.\n Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint('error on get_history from API');
    }
    return null;
  }
}
