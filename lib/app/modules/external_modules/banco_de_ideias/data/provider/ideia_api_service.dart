import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';

class IdeiaApiService {
  IdeiaApiService({FirebaseAuth? firebaseAuth, String? baseUrl})
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

  Future<List<IdeiaResumo>> listarIdeias({
    IdeiaFiltro filtro = const IdeiaFiltro(),
  }) async {
    try {
      return await _listar(
        '/ideias',
        queryParameters: filtro.toQueryParameters(),
      );
    } on StateError catch (error) {
      if (!error.toString().contains('Permissao insuficiente')) {
        rethrow;
      }

      return _listar(
        '/ideias/feed',
        queryParameters: filtro.toQueryParameters(),
      );
    }
  }

  Future<List<IdeiaResumo>> listarMinhasIdeias({
    IdeiaFiltro filtro = const IdeiaFiltro(),
  }) {
    return _listar(
      '/ideias/minhas',
      queryParameters: filtro.toQueryParameters(),
    );
  }

  Future<IdeiaDetalhe> buscarIdeia(String id) async {
    final response = await _send(method: 'GET', path: '/ideias/detalhe/$id');
    final decoded = _decodeJsonBody(response);
    final ideia = _extractObject(decoded, 'ideia');

    if (ideia == null) {
      throw StateError('Ideia nao encontrada.');
    }

    return IdeiaDetalhe.fromJson(ideia);
  }

  Future<IdeiaCadastroOpcoes> carregarOpcoesCadastro() async {
    final response = await _send(method: 'GET', path: '/ideias/opcoes');
    final decoded = _decodeJsonBody(response);
    final map = decoded is Map
        ? Map<String, dynamic>.from(decoded.cast<String, dynamic>())
        : <String, dynamic>{};

    return IdeiaCadastroOpcoes(
      estados: _toOptions(map['estados']),
      tipos: _toOptions(map['tiposIdeia']),
      categorias: _toOptions(map['categorias']),
    );
  }

  Future<void> cadastrarMinhaIdeia(IdeiaCadastroData data) async {
    await _send(
      method: 'POST',
      path: '/ideias/minhas',
      body: jsonEncode(data.toJson()),
      contentType: 'application/json',
    );
  }

  Future<void> atualizarMinhaIdeia(String id, IdeiaCadastroData data) async {
    await _send(
      method: 'PUT',
      path: '/ideias/minhas/$id',
      body: jsonEncode(data.toJson()),
      contentType: 'application/json',
    );
  }

  Future<void> removerMinhaIdeia(String id) async {
    await _send(method: 'DELETE', path: '/ideias/minhas/$id');
  }

  Future<void> favoritarIdeia(String id) async {
    await _send(method: 'POST', path: '/ideias/$id/favorito');
  }

  Future<void> removerFavoritoIdeia(String id) async {
    await _send(method: 'DELETE', path: '/ideias/$id/favorito');
  }

  Future<List<IdeiaResumo>> _listar(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final response = await _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
    final decoded = _decodeJsonBody(response);
    final ideias = _extractList(decoded, 'ideias');

    return ideias
        .whereType<Map>()
        .map(
          (item) => IdeiaResumo.fromJson(
            Map<String, dynamic>.from(item.cast<String, dynamic>()),
          ),
        )
        .toList(growable: false);
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Object? body,
    String? contentType,
    Map<String, String> queryParameters = const {},
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Usuario nao autenticado.');
    }

    final token = await user.getIdToken();
    final request = http.Request(method, _buildUri(path, queryParameters))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        ...?(contentType == null ? null : {'Content-Type': contentType}),
      });

    if (body != null) {
      request.body = body.toString();
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw StateError(_buildErrorMessage(response));
    }

    return response;
  }

  Uri _buildUri(String path, [Map<String, String> queryParameters = const {}]) {
    final normalizedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    if (queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  dynamic _decodeJsonBody(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final body = response.body.trimLeft();

    if (body.isNotEmpty &&
        !contentType.contains('application/json') &&
        body.startsWith('<')) {
      throw StateError(
        'A API retornou HTML em vez de JSON. Verifique a URL base da Cloud Function.',
      );
    }

    if (response.body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('A API retornou uma resposta invalida.');
    }
  }

  List<dynamic> _extractList(dynamic value, String expectedKey) {
    if (value is List) {
      return value;
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value.cast<String, dynamic>());
      final directMatch = map[expectedKey];
      if (directMatch is List) {
        return directMatch;
      }

      final data = map['data'];
      if (data is Map && data[expectedKey] is List) {
        return data[expectedKey] as List;
      }
    }

    return const [];
  }

  Map<String, dynamic>? _extractObject(dynamic value, String expectedKey) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value.cast<String, dynamic>());
      final directMatch = map[expectedKey];
      if (directMatch is Map) {
        return Map<String, dynamic>.from(directMatch.cast<String, dynamic>());
      }

      final data = map['data'];
      if (data is Map && data[expectedKey] is Map) {
        return Map<String, dynamic>.from(
          (data[expectedKey] as Map).cast<String, dynamic>(),
        );
      }
    }

    return null;
  }

  List<IdeiaOpcao> _toOptions(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => IdeiaOpcao.fromJson(
            Map<String, dynamic>.from(item.cast<String, dynamic>()),
          ),
        )
        .where((option) => option.id.isNotEmpty)
        .toList(growable: false);
  }

  String _buildErrorMessage(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.trim().isEmpty ? null : jsonDecode(response.body);
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

    return 'Erro ${response.statusCode} ao acessar a API.';
  }
}
