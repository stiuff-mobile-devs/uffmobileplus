class UserUmmModel {
  Grad? grad;
  Pos? pos;
  ActiveBond? activeBond;

  UserUmmModel({this.grad, this.pos, this.activeBond});

  UserUmmModel.fromJson(Map<String, dynamic> json) {
    grad = json['grad'] != null ? Grad.fromJson(json['grad']) : null;
    pos = json['pos'] != null ? Pos.fromJson(json['pos']) : null;
    activeBond = json['active_bond'] != null
        ? ActiveBond.fromJson(json['active_bond'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (grad != null) {
      data['grad'] = grad!.toJson();
    }
    if (pos != null) {
      data['pos'] = pos!.toJson();
    }
    if (activeBond != null) {
      data['active_bond'] = activeBond!.toJson();
    }
    return data;
  }
}

class Grad {
  List<Matriculas>? matriculas;
  String? nome;

  Grad({this.matriculas, this.nome});

  Grad.fromJson(Map<String, dynamic> json) {
    if (json['matriculas'] != null) {
      matriculas = <Matriculas>[];
      json['matriculas'].forEach((v) {
        matriculas!.add(Matriculas.fromJson(v));
      });
    }
    nome = json['nome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (matriculas != null) {
      data['matriculas'] = matriculas!.map((v) => v.toJson()).toList();
    }
    data['nome'] = nome;
    return data;
  }
}

class Matriculas {
  int? id;
  String? matricula;
  String? statusMatricula;
  int? chCursada;
  int? chTotal;
  double? porcentagem_cursada;
  int? codigoCurso;
  String? nomeCurso;
  int? idstatusaluno;
  int? idsituacaoaluno;
  int? idcurso;
  int? idlocalidade;
  String? statusAlunoDesc;
  String? situacaoAlunoDesc;
  int? anoIngresso;
  int? semestreIngresso;
  String? coeficienterendimento;
  int? codigoemec;
  List<Curriculos>? curriculos;
  Curriculos? curriculo;
  dynamic polo;
  Identificacao? identificacao;

  Matriculas(
      {this.id,
      this.matricula,
      this.statusMatricula,
      this.chCursada,
      this.chTotal,
      this.codigoCurso,
      this.nomeCurso,
      this.idstatusaluno,
      this.idsituacaoaluno,
      this.idcurso,
      this.idlocalidade,
      this.statusAlunoDesc,
      this.situacaoAlunoDesc,
      this.anoIngresso,
      this.semestreIngresso,
      this.coeficienterendimento,
      this.codigoemec,
      this.curriculos,
      this.curriculo,
      this.polo,
      this.identificacao});

  Matriculas.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    matricula = json['matricula'];
    statusMatricula = json['status_matricula'];
    chCursada = json['ch_cursada'];
    chTotal = json['ch_total'];
    codigoCurso = json['codigo_curso'];
    nomeCurso = json['nome_curso'];
    idstatusaluno = json['idstatusaluno'];
    idsituacaoaluno = json['idsituacaoaluno'];
    idcurso = json['idcurso'];
    idlocalidade = json['idlocalidade'];
    statusAlunoDesc = json['status_aluno_desc'];
    situacaoAlunoDesc = json['situacao_aluno_desc'];
    anoIngresso = json['ano_ingresso'];
    semestreIngresso = json['semestre_ingresso'];
    coeficienterendimento = json['coeficienterendimento'];
    codigoemec = json['codigoemec'];
    if (json['curriculos'] != null) {
      curriculos = <Curriculos>[];
      json['curriculos'].forEach((v) {
        curriculos!.add(Curriculos.fromJson(v));
      });
    }
    curriculo =
        json['curriculo'] != null ? Curriculos.fromJson(json['curriculo']) : null;
    polo = json['polo'];
    identificacao = json['identificacao'] != null
        ? Identificacao.fromJson(json['identificacao'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['matricula'] = matricula;
    data['status_matricula'] = statusMatricula;
    data['ch_cursada'] = chCursada;
    data['ch_total'] = chTotal;
    data['codigo_curso'] = codigoCurso;
    data['nome_curso'] = nomeCurso;
    data['idstatusaluno'] = idstatusaluno;
    data['idsituacaoaluno'] = idsituacaoaluno;
    data['idcurso'] = idcurso;
    data['idlocalidade'] = idlocalidade;
    data['status_aluno_desc'] = statusAlunoDesc;
    data['situacao_aluno_desc'] = situacaoAlunoDesc;
    data['ano_ingresso'] = anoIngresso;
    data['semestre_ingresso'] = semestreIngresso;
    data['coeficienterendimento'] = coeficienterendimento;
    data['codigoemec'] = codigoemec;
    if (curriculos != null) {
      data['curriculos'] = curriculos!.map((v) => v.toJson()).toList();
    }
    if (curriculo != null) {
      data['curriculo'] = curriculo!.toJson();
    }
    data['polo'] = polo;
    if (identificacao != null) {
      data['identificacao'] = identificacao!.toJson();
    }
    return data;
  }
}

class Curriculos {
  int? chTotal;
  int? chObrigatoriaObtida;
  int? chEletivaObtida;
  dynamic integralizado;
  int? chOptativaObtida;
  String? identificador;
  int? chAtividadeComplementar;
  int? chExtensao;
  double? crMaximo;
  double? crMediana;
  int? chLivreObrigatoria;
  int? chObtidaTotal;
  String? datavinculacao;

  Curriculos(
      {this.chTotal,
      this.chObrigatoriaObtida,
      this.chEletivaObtida,
      this.integralizado,
      this.chOptativaObtida,
      this.identificador,
      this.chAtividadeComplementar,
      this.crMaximo,
      this.crMediana,
      this.datavinculacao});

  Curriculos.fromJson(Map<String, dynamic> json) {
    chTotal = json['ch_total'];
    chObrigatoriaObtida = json['ch_obrigatoria_obtida'];
    chEletivaObtida = json['ch_eletiva_obtida'];
    integralizado = json['integralizado'];
    chOptativaObtida = json['ch_optativa_obtida'];
    identificador = json['identificador'];
    chAtividadeComplementar = json['ch_atividade_complementar'];
    crMaximo = json['cr_maximo'];
    crMediana = json['cr_mediana'];
    datavinculacao = json['datavinculacao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ch_total'] = chTotal;
    data['ch_obrigatoria_obtida'] = chObrigatoriaObtida;
    data['ch_eletiva_obtida'] = chEletivaObtida;
    data['integralizado'] = integralizado;
    data['ch_optativa_obtida'] = chOptativaObtida;
    data['identificador'] = identificador;
    data['ch_atividade_complementar'] = chAtividadeComplementar;
    data['cr_maximo'] = crMaximo;
    data['cr_mediana'] = crMediana;
    data['datavinculacao'] = datavinculacao;
    return data;
  }
}

class Identificacao {
  String? iduff;
  String? nome;
  String? nomesocial;

  Identificacao({this.iduff, this.nome, this.nomesocial});

  Identificacao.fromJson(Map<String, dynamic> json) {
    iduff = json['iduff'];
    nome = json['nome'];
    nomesocial = json['nomesocial'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['iduff'] = iduff;
    data['nome'] = nome;
    data['nomesocial'] = nomesocial;
    return data;
  }
}

class Pos {
  List<Alunos>? alunos;

  Pos({this.alunos});

  Pos.fromJson(Map<String, dynamic> json) {
    if (json['alunos'] != null) {
      alunos = <Alunos>[];
      json['alunos'].forEach((v) {
        alunos!.add(Alunos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (alunos != null) {
      data['alunos'] = alunos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Alunos {
  String? matricula;
  String? nome;
  String? cursoNome;
  String? descricao;
  String? situacao;

  Alunos({this.matricula, this.nome, this.cursoNome, this.descricao, this.situacao});

  Alunos.fromJson(Map<String, dynamic> json) {
    matricula = json['matricula'];
    nome = json['nome'];
    cursoNome = json['curso_nome'];
    descricao = json['descricao'];
    situacao = json['situacao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['matricula'] = matricula;
    data['nome'] = nome;
    data['curso_nome'] = cursoNome;
    data['descricao'] = descricao;
    data['situacao'] = situacao;
    return data;
  }
}

class ActiveBond {
  Objects? objects;

  ActiveBond({this.objects});

  ActiveBond.fromJson(Map<String, dynamic> json) {
    objects = json['objects'] != null ? Objects.fromJson(json['objects']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (objects != null) {
      data['objects'] = objects!.toJson();
    }
    return data;
  }
}

class Objects {
  List<OuterObject>? outerObject;

  Objects({this.outerObject});

  Objects.fromJson(Map<String, dynamic> json) {
    if (json['object'] != null) {
      outerObject = <OuterObject>[];
      json['object'].forEach((v) {
        outerObject!.add(OuterObject.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (outerObject != null) {
      data['object'] = outerObject!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OuterObject {
  Usuario? usuario;
  List<InnerObject>? innerObjects;

  OuterObject({this.usuario, this.innerObjects});

  OuterObject.fromJson(Map<String, dynamic> json) {
    usuario = json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null;
    if (json['object'] != null) {
      innerObjects = <InnerObject>[];
      try {
        if (json['object'] is List) {
          json['object'].forEach((v) {
            innerObjects!.add(InnerObject.fromJson(v));
          });
        } else {
          innerObjects!.add(InnerObject.fromJson(json['object']));
        }
      } catch (e) {
        // ignore parsing errors
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (usuario != null) {
      data['usuario'] = usuario!.toJson();
    }
    if (innerObjects != null) {
      data['object'] = innerObjects!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Usuario {
  String? id;
  String? nome;
  String? cpf;
  String? ddd;
  String? tel;
  String? rg;
  String? iduff;

  Usuario({this.id, this.nome, this.cpf, this.ddd, this.tel, this.rg, this.iduff});

  Usuario.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    cpf = json['cpf'];
    ddd = json['ddd'];
    tel = json['tel'];
    rg = json['rg'];
    iduff = json['iduff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    data['cpf'] = cpf;
    data['ddd'] = ddd;
    data['tel'] = tel;
    data['rg'] = rg;
    data['iduff'] = iduff;
    return data;
  }
}

class InnerObject {
  Vinculacao? vinculacao;

  InnerObject({this.vinculacao});

  InnerObject.fromJson(Map<String, dynamic> json) {
    vinculacao = json['vinculacao'] != null
        ? Vinculacao.fromJson(json['vinculacao'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vinculacao != null) {
      data['vinculacao'] = vinculacao!.toJson();
    }
    return data;
  }
}

class Vinculacao {
  String? id;
  String? matricula;
  String? localidadeId;
  String? vinculoId;
  String? vinculo;

  Vinculacao({this.id, this.matricula, this.localidadeId, this.vinculoId, this.vinculo});

  Vinculacao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    matricula = json['matricula'];
    localidadeId = json['localidade_id'];
    vinculoId = json['vinculo_id'];
    vinculo = json['vinculo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['matricula'] = matricula;
    data['localidade_id'] = localidadeId;
    data['vinculo_id'] = vinculoId;
    data['vinculo'] = vinculo;
    return data;
  }
}