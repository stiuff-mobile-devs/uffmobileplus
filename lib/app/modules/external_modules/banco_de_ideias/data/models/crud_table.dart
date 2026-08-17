import 'package:flutter/material.dart';

enum CrudFieldType { text, multiline, select }

class CrudField {
  const CrudField({
    required this.name,
    required this.label,
    this.type = CrudFieldType.text,
    this.required = true,
    this.recordPath,
    this.optionsPath,
    this.optionsItemsKey,
    this.optionLabelPaths = const ['nome'],
  });

  final String name;
  final String label;
  final CrudFieldType type;
  final bool required;
  final String? recordPath;
  final String? optionsPath;
  final String? optionsItemsKey;
  final List<String> optionLabelPaths;
}

class CrudDisplayField {
  const CrudDisplayField(this.label, this.path);

  final String label;
  final String path;
}

class CrudTable {
  const CrudTable({
    required this.title,
    required this.path,
    required this.itemsKey,
    required this.icon,
    required this.fields,
    this.keyPaths = const ['id'],
    this.titlePaths = const ['nome'],
    this.subtitleFields = const [],
  });

  final String title;
  final String path;
  final String itemsKey;
  final IconData icon;
  final List<CrudField> fields;
  final List<String> keyPaths;
  final List<String> titlePaths;
  final List<CrudDisplayField> subtitleFields;
}

const nomeField = CrudField(name: 'nome', label: 'Nome');

const crudTables = <CrudTable>[
  CrudTable(
    title: 'Categorias',
    path: '/categorias',
    itemsKey: 'categorias',
    icon: Icons.category_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'Departamentos',
    path: '/departamentos',
    itemsKey: 'departamentos',
    icon: Icons.business_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'Cursos',
    path: '/cursos',
    itemsKey: 'cursos',
    icon: Icons.school_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'Estados',
    path: '/estados',
    itemsKey: 'estados',
    icon: Icons.flag_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'Tipos de ideia',
    path: '/tipos-ideia',
    itemsKey: 'tipoIdeias',
    icon: Icons.lightbulb_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'Tipos de ideia do usuario',
    path: '/tipos-ideia-usuario',
    itemsKey: 'tipoIdeiaUsuarios',
    icon: Icons.person_pin_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'Perfis',
    path: '/perfis',
    itemsKey: 'perfils',
    icon: Icons.admin_panel_settings_rounded,
    fields: [
      nomeField,
      CrudField(
        name: 'descricao',
        label: 'Descricao',
        type: CrudFieldType.multiline,
        required: false,
      ),
    ],
    subtitleFields: [CrudDisplayField('Descricao', 'descricao')],
  ),
  CrudTable(
    title: 'Permissoes',
    path: '/permissoes',
    itemsKey: 'permissaos',
    icon: Icons.lock_rounded,
    fields: [
      CrudField(name: 'recurso', label: 'Recurso'),
      CrudField(name: 'acao', label: 'Acao'),
      CrudField(
        name: 'descricao',
        label: 'Descricao',
        type: CrudFieldType.multiline,
        required: false,
      ),
    ],
    titlePaths: ['recurso', 'acao'],
    subtitleFields: [CrudDisplayField('Descricao', 'descricao')],
  ),
  CrudTable(
    title: 'Permissoes por perfil',
    path: '/perfil-permissoes',
    itemsKey: 'perfilPermissaos',
    icon: Icons.rule_rounded,
    keyPaths: ['perfil.id', 'permissao.id'],
    fields: [
      CrudField(
        name: 'perfilId',
        label: 'Perfil',
        type: CrudFieldType.select,
        recordPath: 'perfil.id',
        optionsPath: '/perfis',
        optionsItemsKey: 'perfils',
      ),
      CrudField(
        name: 'permissaoId',
        label: 'Permissao',
        type: CrudFieldType.select,
        recordPath: 'permissao.id',
        optionsPath: '/permissoes',
        optionsItemsKey: 'permissaos',
        optionLabelPaths: ['recurso', 'acao'],
      ),
    ],
    titlePaths: ['perfil.nome', 'permissao.recurso', 'permissao.acao'],
  ),
  CrudTable(
    title: 'Ideias',
    path: '/ideias',
    itemsKey: 'ideias',
    icon: Icons.tips_and_updates_rounded,
    fields: [
      CrudField(name: 'titulo', label: 'Titulo'),
      CrudField(
        name: 'descricao',
        label: 'Descricao',
        type: CrudFieldType.multiline,
      ),
      CrudField(
        name: 'estadoId',
        label: 'Estado',
        type: CrudFieldType.select,
        recordPath: 'estado.id',
        optionsPath: '/estados',
        optionsItemsKey: 'estados',
      ),
      CrudField(
        name: 'tipoId',
        label: 'Tipo de ideia',
        type: CrudFieldType.select,
        recordPath: 'tipo.id',
        optionsPath: '/tipos-ideia',
        optionsItemsKey: 'tipoIdeias',
      ),
    ],
    titlePaths: ['titulo'],
    subtitleFields: [
      CrudDisplayField('Estado', 'estado.nome'),
      CrudDisplayField('Tipo', 'tipo.nome'),
      CrudDisplayField('Descricao', 'descricao'),
    ],
  ),
  CrudTable(
    title: 'Categorias das ideias',
    path: '/ideia-categorias',
    itemsKey: 'ideiaCategorias',
    icon: Icons.account_tree_rounded,
    keyPaths: ['ideia.id', 'categoria.id'],
    fields: [
      CrudField(
        name: 'ideiaId',
        label: 'Ideia',
        type: CrudFieldType.select,
        recordPath: 'ideia.id',
        optionsPath: '/ideias',
        optionsItemsKey: 'ideias',
        optionLabelPaths: ['titulo'],
      ),
      CrudField(
        name: 'categoriaId',
        label: 'Categoria',
        type: CrudFieldType.select,
        recordPath: 'categoria.id',
        optionsPath: '/categorias',
        optionsItemsKey: 'categorias',
      ),
    ],
    titlePaths: ['ideia.titulo', 'categoria.nome'],
  ),
  CrudTable(
    title: 'Usuarios das ideias',
    path: '/ideia-usuarios',
    itemsKey: 'ideiaUsuarios',
    icon: Icons.groups_rounded,
    keyPaths: ['ideia.id', 'usuario.id'],
    fields: [
      CrudField(
        name: 'ideiaId',
        label: 'Ideia',
        type: CrudFieldType.select,
        recordPath: 'ideia.id',
        optionsPath: '/ideias',
        optionsItemsKey: 'ideias',
        optionLabelPaths: ['titulo'],
      ),
      CrudField(
        name: 'usuarioId',
        label: 'Usuario',
        type: CrudFieldType.select,
        recordPath: 'usuario.id',
        optionsPath: '/usuarios',
        optionsItemsKey: 'usuarios',
        optionLabelPaths: ['nome', 'email'],
      ),
      CrudField(
        name: 'tipoIdeiaUsuarioId',
        label: 'Tipo de usuario na ideia',
        type: CrudFieldType.select,
        recordPath: 'tipoIdeiaUsuario.id',
        optionsPath: '/tipos-ideia-usuario',
        optionsItemsKey: 'tipoIdeiaUsuarios',
      ),
    ],
    titlePaths: ['ideia.titulo', 'usuario.nome'],
    subtitleFields: [
      CrudDisplayField('Email', 'usuario.email'),
      CrudDisplayField('Tipo', 'tipoIdeiaUsuario.nome'),
    ],
  ),
  CrudTable(
    title: 'Usuarios',
    path: '/usuarios',
    itemsKey: 'usuarios',
    icon: Icons.person_rounded,
    fields: [
      CrudField(name: 'uidFirebase', label: 'UID Firebase', required: false),
      nomeField,
      CrudField(name: 'email', label: 'Email'),
      CrudField(
        name: 'perfilId',
        label: 'Perfil',
        type: CrudFieldType.select,
        required: false,
        recordPath: 'perfil.id',
        optionsPath: '/perfis',
        optionsItemsKey: 'perfils',
      ),
      CrudField(
        name: 'departamentoId',
        label: 'Departamento',
        type: CrudFieldType.select,
        required: false,
        recordPath: 'departamento.id',
        optionsPath: '/departamentos',
        optionsItemsKey: 'departamentos',
      ),
      CrudField(
        name: 'cursoId',
        label: 'Curso',
        type: CrudFieldType.select,
        required: false,
        recordPath: 'curso.id',
        optionsPath: '/cursos',
        optionsItemsKey: 'cursos',
      ),
    ],
    titlePaths: ['nome'],
    subtitleFields: [
      CrudDisplayField('Email', 'email'),
      CrudDisplayField('Perfil', 'perfil.nome'),
    ],
  ),
];
