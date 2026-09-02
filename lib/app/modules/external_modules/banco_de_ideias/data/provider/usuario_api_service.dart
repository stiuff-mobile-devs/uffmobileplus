import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/usuario_atual.dart';
import 'crud_api_service.dart';

class CadastroUsuarioOpcoes {
  const CadastroUsuarioOpcoes({
    required this.cursos,
    required this.departamentos,
  });

  final List<CrudRecord> cursos;
  final List<CrudRecord> departamentos;
}

class UsuarioCadastroData {
  const UsuarioCadastroData({
    required this.nome,
    required this.isAluno,
    this.cursoId,
    this.departamentoId,
  });

  final String nome;
  final bool isAluno;
  final String? cursoId;
  final String? departamentoId;

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'isAluno': isAluno,
      'cursoId': cursoId,
      'departamentoId': departamentoId,
    };
  }
}

class UsuarioApiService {
  UsuarioApiService({FirebaseAuth? firebaseAuth, String? baseUrl})
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

  Future<UsuarioAtual?> carregarUsuarioAtual() async {
    final response = await _send(method: 'GET', path: '/usuarios/me');

    if (_isUsuarioNaoCadastrado(response)) {
      return null;
    }

    _throwIfError(response);
    final decoded = _decodeBody(response.body);
    final map = decoded is Map
        ? Map<String, dynamic>.from(decoded.cast<String, dynamic>())
        : <String, dynamic>{};

    return UsuarioAtual.fromJson(map);
  }

  Future<CadastroUsuarioOpcoes> carregarOpcoesCadastro() async {
    final response = await _send(method: 'GET', path: '/usuarios/me/opcoes');
    _throwIfError(response);

    final decoded = _decodeBody(response.body);
    final map = decoded is Map
        ? Map<String, dynamic>.from(decoded.cast<String, dynamic>())
        : <String, dynamic>{};

    return CadastroUsuarioOpcoes(
      cursos: _toRecords(map['cursos']),
      departamentos: _toRecords(map['departamentos']),
    );
  }

  Future<void> cadastrarUsuarioAtual(UsuarioCadastroData data) async {
    final response = await _send(
      method: 'POST',
      path: '/usuarios/me',
      body: jsonEncode(data.toJson()),
      contentType: 'application/json',
    );

    _throwIfError(response);
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Object? body,
    String? contentType,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('bdi_usuario_nao_autenticado'.tr);
    }

    final token = await user.getIdToken();
    final request = http.Request(method, _buildUri(path))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        ...?(contentType == null ? null : {'Content-Type': contentType}),
      });

    if (body != null) {
      request.body = body.toString();
    }

    return http.Response.fromStream(await request.send());
  }

  Uri _buildUri(String path) {
    final normalizedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  List<CrudRecord> _toRecords(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item.cast<String, dynamic>());
          final id = map['id']?.toString() ?? '';
          final nome = map['nome']?.toString() ?? '';

          return CrudRecord(
            id: id,
            nome: nome.isEmpty ? 'bdi_sem_nome'.tr : nome,
            raw: map,
          );
        })
        .toList(growable: false);
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      throw FormatException('bdi_resposta_invalida_api'.tr);
    }
  }

  bool _isUsuarioNaoCadastrado(http.Response response) {
    if (response.statusCode == 404) {
      return true;
    }

    dynamic decoded;
    try {
      decoded = _decodeBody(response.body);
    } on FormatException {
      return false;
    }

    if (decoded is Map && decoded['error'] != null) {
      final error = decoded['error'].toString().toLowerCase();
      return error.contains('usuario nao cadastrado') ||
          error.contains('usuario não cadastrado');
    }

    return false;
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode < 400) {
      return;
    }

    final decoded = _decodeBody(response.body);
    if (decoded is Map && decoded['error'] != null) {
      final details = decoded['details'];
      if (details != null) {
        throw UsuarioApiException(
          response.statusCode,
          '${decoded['error']}: $details',
        );
      }
      throw UsuarioApiException(
        response.statusCode,
        decoded['error'].toString(),
      );
    }

    throw UsuarioApiException(
      response.statusCode,
      'Erro ${response.statusCode} ao acessar a API.',
    );
  }
}

class UsuarioApiException implements Exception {
  const UsuarioApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'Erro $statusCode: $message';
}
