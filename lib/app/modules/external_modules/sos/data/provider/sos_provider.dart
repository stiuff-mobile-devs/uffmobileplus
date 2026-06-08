import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/config/secrets.dart';

class SosDispatchResult {
  final String? incidentId;
  final String? meetLink;
  final bool shouldStop;

  SosDispatchResult({this.incidentId, this.meetLink, this.shouldStop = false});
}

class SosProvider {
  Future<SosDispatchResult?> postDispatchAlert({
    String? incidentId,
    required String action,
    required String pointType,
    required String status,
    String? nome,
    required String matricula,
    String? email,
    required double lat,
    required double lng,
  }) async {
    final Uri url = Uri.parse(Secrets.sosApiUrl);

    final body = jsonEncode({
      "action": action,
      "pointType": pointType,
      "status": status,
      if (incidentId != null) "incidentId": incidentId,
      "user": {"nome": nome, "matricula": matricula, "email": email},
      "location": {
        "latitude": lat,
        "longitude": lng,
        "capturedAt": DateTime.now().toIso8601String(),
      },
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Type': 'PluginSOS'},
        body: body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Dispatch returned ${response.statusCode}: ${response.body}',
        );
      }

      if (response.body.isEmpty) {
        return SosDispatchResult(incidentId: incidentId);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final dynamic returnedIncidentId =
            decoded['incidentId'] ?? decoded['id'] ?? decoded['incident_id'];

        final String? resolvedId =
            (returnedIncidentId != null &&
                returnedIncidentId.toString().isNotEmpty)
            ? returnedIncidentId.toString()
            : incidentId;

        // Busca meet_link no raiz ou dentro de emergency_call
        final emergencyCall =
            decoded['emergency_call'] as Map<String, dynamic>?;
        final String? meetLink =
            decoded['meet_link'] as String? ??
            emergencyCall?['meet_link'] as String?;

        final bool shouldStop = decoded['action'] == 'stop';

        return SosDispatchResult(
          incidentId: resolvedId,
          meetLink: meetLink,
          shouldStop: shouldStop,
        );
      }

      return SosDispatchResult(incidentId: incidentId);
    } catch (e) {
      print("ERRO DE REDE/CONEXÃO NO SOS: $e");
      rethrow;
    }
  }
}
