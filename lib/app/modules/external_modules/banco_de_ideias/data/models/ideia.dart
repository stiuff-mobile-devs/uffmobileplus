class IdeiaResumo {
  const IdeiaResumo({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.estado,
    required this.tipo,
    required this.categorias,
    required this.podeAdministrar,
    required this.favorita,
    required this.quantidadeSeguidores,
    this.tipoVinculo,
    required this.raw,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String estado;
  final String tipo;
  final List<IdeiaOpcao> categorias;
  final bool podeAdministrar;
  final bool favorita;
  final int quantidadeSeguidores;
  final String? tipoVinculo;
  final Map<String, dynamic> raw;

  factory IdeiaResumo.fromJson(Map<String, dynamic> json) {
    return IdeiaResumo(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '(sem titulo)',
      descricao: json['descricao']?.toString() ?? '',
      estado: nomeDe(json['estado']),
      tipo: nomeDe(json['tipo']),
      categorias: IdeiaDetalhe.toCategorias(json['ideiaCategorias_on_ideia']),
      podeAdministrar: _podeAdministrar(json),
      favorita: _favorita(json),
      quantidadeSeguidores: _quantidadeSeguidores(json),
      tipoVinculo: nomeDe(json['tipoIdeiaUsuario'], permitirVazio: true),
      raw: json,
    );
  }

  static bool _podeAdministrar(Map<String, dynamic> json) {
    final permissoes = json['permissoes'];
    if (permissoes is Map) {
      return permissoes['podeAdministrar'] == true;
    }
    return json['podeAdministrar'] == true;
  }

  static bool _favorita(Map<String, dynamic> json) {
    final permissoes = json['permissoes'];
    if (permissoes is Map && permissoes['favorita'] is bool) {
      return permissoes['favorita'] == true;
    }

    return nomeDe(
          json['tipoIdeiaUsuario'],
          permitirVazio: true,
        ).trim().toLowerCase() ==
        'seguidor';
  }

  static int _quantidadeSeguidores(Map<String, dynamic> json) {
    final quantidade = json['quantidadeSeguidores'] ?? json['seguidoresCount'];
    if (quantidade is int) {
      return quantidade;
    }
    if (quantidade is num) {
      return quantidade.toInt();
    }
    if (quantidade is String) {
      return int.tryParse(quantidade) ?? 0;
    }
    return 0;
  }
}

class IdeiaOpcao {
  const IdeiaOpcao({required this.id, required this.nome});

  final String id;
  final String nome;

  factory IdeiaOpcao.fromJson(Map<String, dynamic> json) {
    return IdeiaOpcao(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '(sem nome)',
    );
  }
}

class IdeiaParticipante {
  const IdeiaParticipante({
    required this.nome,
    required this.email,
    required this.tipoVinculo,
  });

  final String nome;
  final String email;
  final String tipoVinculo;

  factory IdeiaParticipante.fromJson(Map<String, dynamic> json) {
    return IdeiaParticipante(
      nome: nomeDe(json['usuario']),
      email: _emailDe(json['usuario']),
      tipoVinculo: nomeDe(json['tipoIdeiaUsuario'], permitirVazio: true),
    );
  }

  static String _emailDe(dynamic value) {
    if (value is Map) {
      return value['email']?.toString() ?? '';
    }
    return '';
  }
}

class IdeiaDetalhe {
  const IdeiaDetalhe({
    required this.resumo,
    required this.categorias,
    required this.participantes,
  });

  final IdeiaResumo resumo;
  final List<IdeiaOpcao> categorias;
  final List<IdeiaParticipante> participantes;

  factory IdeiaDetalhe.fromJson(Map<String, dynamic> json) {
    return IdeiaDetalhe(
      resumo: IdeiaResumo.fromJson(json),
      categorias: toCategorias(json['ideiaCategorias_on_ideia']),
      participantes: _toParticipantes(json['ideiaUsuarios_on_ideia']),
    );
  }

  static List<IdeiaOpcao> toCategorias(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => item['categoria'])
        .whereType<Map>()
        .map(
          (categoria) => IdeiaOpcao.fromJson(
            Map<String, dynamic>.from(categoria.cast<String, dynamic>()),
          ),
        )
        .where((categoria) => categoria.id.isNotEmpty)
        .toList(growable: false);
  }

  static List<IdeiaParticipante> _toParticipantes(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => IdeiaParticipante.fromJson(
            Map<String, dynamic>.from(item.cast<String, dynamic>()),
          ),
        )
        .where((participante) => participante.nome.isNotEmpty)
        .toList(growable: false);
  }
}

class IdeiaFiltro {
  const IdeiaFiltro({this.nome = '', this.tipoId, this.categoriaId});

  final String nome;
  final String? tipoId;
  final String? categoriaId;

  bool get isEmpty =>
      nome.trim().isEmpty &&
      (tipoId == null || tipoId!.isEmpty) &&
      (categoriaId == null || categoriaId!.isEmpty);

  Map<String, String> toQueryParameters() {
    return {
      if (nome.trim().isNotEmpty) 'nome': nome.trim(),
      if (tipoId != null && tipoId!.isNotEmpty) 'tipoId': tipoId!,
      if (categoriaId != null && categoriaId!.isNotEmpty)
        'categoriaId': categoriaId!,
    };
  }
}

class IdeiaCadastroOpcoes {
  const IdeiaCadastroOpcoes({
    required this.estados,
    required this.tipos,
    required this.categorias,
  });

  final List<IdeiaOpcao> estados;
  final List<IdeiaOpcao> tipos;
  final List<IdeiaOpcao> categorias;
}

class IdeiaCadastroData {
  const IdeiaCadastroData({
    required this.titulo,
    required this.descricao,
    required this.estadoId,
    required this.tipoId,
    required this.categoriaIds,
  });

  final String titulo;
  final String descricao;
  final String estadoId;
  final String tipoId;
  final List<String> categoriaIds;

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'estadoId': estadoId,
      'tipoId': tipoId,
      'categoriaIds': categoriaIds,
    };
  }
}

String nomeDe(dynamic value, {bool permitirVazio = false}) {
  if (value is Map) {
    final nome = value['nome']?.toString() ?? '';
    if (nome.isNotEmpty || permitirVazio) {
      return nome;
    }
  }
  return permitirVazio ? '' : '(sem informacao)';
}
