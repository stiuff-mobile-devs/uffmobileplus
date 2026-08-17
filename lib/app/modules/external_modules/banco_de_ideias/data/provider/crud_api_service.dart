import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';

class CrudRecord {
  const CrudRecord({required this.id, required this.nome, required this.raw});

  final String id;
  final String nome;
  final Map<String, dynamic> raw;
}

class CrudApiService {
  CrudApiService({FirebaseAuth? firebaseAuth, String? baseUrl})
    : _firebaseAuth =
          firebaseAuth ??
          FirebaseAuth.instanceFor(app: Firebase.app('banco_de_ideias')),
      _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'CRUD_API_BASE_URL',
    defaultValue: 'https://api-k3j5os4cvq-rj.a.run.app/',
  );

  final FirebaseAuth _firebaseAuth;
  final String _baseUrl;

  Future<List<CrudRecord>> listRecords({
    required String path,
    required String itemsKey,
  }) async {
    final response = await _get(path);
    final decoded = _decodeJsonBody(response);
    final items = _extractList(decoded, itemsKey);

    return items
        .whereType<Map>()
        .map(
          (item) => _toRecord(
            Map<String, dynamic>.from(item.cast<String, dynamic>()),
          ),
        )
        .toList(growable: false);
  }

  Future<void> createRecord({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    await _sendJson(method: 'POST', path: path, body: data);
  }

  Future<void> updateRecord({
    required CrudTable table,
    required CrudRecord record,
    required Map<String, dynamic> data,
  }) async {
    await _sendJson(
      method: 'PUT',
      path: _recordPath(table, record),
      body: data,
    );
  }

  Future<void> deleteRecord({
    required CrudTable table,
    required CrudRecord record,
  }) async {
    await _sendJson(method: 'DELETE', path: _recordPath(table, record));
  }

  Future<List<CrudRecord>> listOptions({
    required String path,
    required String itemsKey,
  }) {
    return listRecords(path: path, itemsKey: itemsKey);
  }

  Future<http.Response> _get(String path) {
    return _send(method: 'GET', path: path);
  }

  Future<http.Response> _sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) {
    return _send(
      method: method,
      path: path,
      body: body == null ? null : jsonEncode(body),
      contentType: 'application/json',
    );
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Object? body,
    String? contentType,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Usuario nao autenticado.');
    }

    final token = await user.getIdToken();
    final uri = _buildUri(path);

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      ...?(contentType == null ? null : {'Content-Type': contentType}),
    };

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = body is String ? body : jsonEncode(body);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw StateError(_buildErrorMessage(response));
    }

    _ensureJsonResponse(response);

    return response;
  }

  Uri _buildUri(String path) {
    final normalizedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  dynamic _decodeJsonBody(http.Response response) {
    _ensureJsonResponse(response);

    return _decodeBody(response.body);
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      throw const FormatException('A API retornou uma resposta invalida.');
    }
  }

  void _ensureJsonResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final body = response.body.trimLeft();

    if (body.isEmpty || contentType.contains('application/json')) {
      return;
    }

    if (body.startsWith('<')) {
      throw StateError(
        'A API retornou HTML em vez de JSON. Verifique se a Cloud Function '
        'foi implantada e se a URL base esta correta: ${_buildUri('')}',
      );
    }
  }

  String _recordPath(CrudTable table, CrudRecord record) {
    final keyValues = table.keyPaths
        .map((path) => _readValue(record.raw, path)?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .map(Uri.encodeComponent)
        .toList(growable: false);

    if (keyValues.isEmpty) {
      throw StateError('Registro sem chave para ${table.title}.');
    }

    return '${table.path}/${keyValues.join('/')}';
  }

  CrudRecord _toRecord(Map<String, dynamic> item) {
    final id =
        item['id']?.toString() ??
        _readValue(item, 'ideia.id')?.toString() ??
        _readValue(item, 'perfil.id')?.toString() ??
        '';
    final nome = _bestDisplayValue(item);

    return CrudRecord(
      id: id,
      nome: nome.isEmpty ? '(sem nome)' : nome,
      raw: item,
    );
  }

  String _bestDisplayValue(Map<String, dynamic> item) {
    for (final path in const [
      'nome',
      'titulo',
      'email',
      'recurso',
      'perfil.nome',
      'ideia.titulo',
    ]) {
      final value = _readValue(item, path)?.toString() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  dynamic _readValue(Map<String, dynamic> source, String path) {
    dynamic current = source;
    for (final part in path.split('.')) {
      if (current is! Map) {
        return null;
      }
      current = current[part];
    }
    return current;
  }

  List<dynamic> _extractList(
    dynamic value,
    String expectedKey, [
    int depth = 0,
  ]) {
    if (value == null || depth > 6) {
      return const [];
    }

    if (value is List) {
      return value;
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value.cast<String, dynamic>());

      final directMatch = map[expectedKey];
      if (directMatch is List) {
        return directMatch;
      }

      for (final nestedKey in const ['data', 'result']) {
        final nestedValue = map[nestedKey];
        if (nestedValue is List) {
          return nestedValue;
        }
        final nestedMatch = _extractList(nestedValue, expectedKey, depth + 1);
        if (nestedMatch.isNotEmpty) {
          return nestedMatch;
        }
      }

      for (final entryValue in map.values) {
        final nestedMatch = _extractList(entryValue, expectedKey, depth + 1);
        if (nestedMatch.isNotEmpty) {
          return nestedMatch;
        }
      }
    }

    return const [];
  }

  String _buildErrorMessage(http.Response response) {
    dynamic decoded;
    try {
      decoded = _decodeBody(response.body);
    } on FormatException {
      decoded = null;
    }

    if (decoded is Map && decoded['error'] != null) {
      final details = decoded['details'];
      if (details != null) {
        return '${decoded['error']}: $details';
      }
      return decoded['error'].toString();
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html') ||
        response.body.trimLeft().startsWith('<')) {
      return 'A API retornou HTML em vez de JSON (${response.statusCode}). '
          'Verifique se a URL base aponta para a Cloud Function implantada.';
    }

    return 'Erro ${response.statusCode} ao acessar a API.';
  }
}
