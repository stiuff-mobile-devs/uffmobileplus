import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

String? _incidentId;
String? _apiUrl;
String? _matricula;
String? _nome;
String? _email;
StreamSubscription<Position>? _positionSubscription;
bool _isSending = false;

@pragma('vm:entry-point')
void onSosStart(ServiceInstance service) {
  service.on('sosConfig').listen((event) {
    if (event == null) return;
    _incidentId = event['incidentId'] as String?;
    _apiUrl = event['apiUrl'] as String?;
    _matricula = event['matricula'] as String?;
    _nome = event['nome'] as String?;
    _email = event['email'] as String?;
    _startPositionStream(service);
  });

  service.on('stopSos').listen((_) async {
    await _sendDispatch(action: 'stop', pointType: 'live', status: 'closed');
    _cleanup();
    service.stopSelf();
  });
}

void _startPositionStream(ServiceInstance service) {
  _positionSubscription?.cancel();

  late LocationSettings locationSettings;

  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      intervalDuration: const Duration(seconds: 10),
    );
  } else if (Platform.isIOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.other,
      distanceFilter: 10,
      showBackgroundLocationIndicator: true,
      pauseLocationUpdatesAutomatically: true,
    );
  } else {
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }

  _positionSubscription =
      Geolocator.getPositionStream(locationSettings: locationSettings).listen((
        Position position,
      ) async {
        if (_isSending) return;
        _isSending = true;
        try {
          final bool shouldStop = await _sendDispatch(
            action: 'update',
            pointType: 'live',
            status: 'active',
            lat: position.latitude,
            lng: position.longitude,
          );
          if (shouldStop) {
            _cleanup();
            service.invoke('sosStopped', {});
            service.stopSelf();
          }
        } finally {
          _isSending = false;
        }
      });
}

/// Retorna true se o servidor respondeu com action:'stop'
Future<bool> _sendDispatch({
  required String action,
  required String pointType,
  required String status,
  double? lat,
  double? lng,
}) async {
  final String? url = _apiUrl;
  final String? matricula = _matricula;
  if (url == null || matricula == null) return false;

  double effectiveLat = lat ?? 0;
  double effectiveLng = lng ?? 0;
  if (lat == null) {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        effectiveLat = pos.latitude;
        effectiveLng = pos.longitude;
      }
    } catch (_) {}
  }

  try {
    final body = jsonEncode({
      "action": action,
      "pointType": pointType,
      "status": status,
      if (_incidentId != null) "incidentId": _incidentId,
      "user": {"nome": _nome, "matricula": matricula, "email": _email},
      "location": {
        "latitude": effectiveLat,
        "longitude": effectiveLng,
        "capturedAt": DateTime.now().toIso8601String(),
      },
    });

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', 'Type': 'PluginSOS'},
          body: body,
        )
        .timeout(const Duration(seconds: 10));

    print(
      "[SOS BG] RESPONSE ($action) status=${response.statusCode}: ${response.body}",
    );

    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final dynamic returnedId =
            decoded['incidentId'] ?? decoded['id'] ?? decoded['incident_id'];
        if (returnedId != null && returnedId.toString().isNotEmpty) {
          _incidentId = returnedId.toString();
        }
        final bool shouldStop = decoded['action'] == 'stop';
        if (shouldStop) {
          print("[SOS BG] === STOP RECEBIDO DO SERVIDOR ===");
          print("[SOS BG] incidentId: $_incidentId");
          print("[SOS BG] resolved_at: ${decoded['resolved_at']}");
          print("[SOS BG] =====================================");
        }
        return shouldStop;
      }
    }
  } catch (e) {
    print("[SOS BG] ERRO ao enviar ($action): $e");
  }
  return false;
}

void _cleanup() {
  _positionSubscription?.cancel();
  _positionSubscription = null;
  _isSending = false;
  _incidentId = null;
  _apiUrl = null;
  _matricula = null;
  _nome = null;
  _email = null;
}
