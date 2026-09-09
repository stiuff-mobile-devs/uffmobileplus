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

// Note: `title`/`label` values below are translation KEYS (resolved via
// `.tr` at the render sites), not display text, so this const list can
// keep being built at compile time.
const nomeField = CrudField(name: 'nome', label: 'nome');

const crudTables = <CrudTable>[
  CrudTable(
    title: 'bdi_tabela_categorias',
    path: '/categorias',
    itemsKey: 'categorias',
    icon: Icons.category_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'bdi_tabela_departamentos',
    path: '/departamentos',
    itemsKey: 'departamentos',
    icon: Icons.business_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'bdi_tabela_cursos',
    path: '/cursos',
    itemsKey: 'cursos',
    icon: Icons.school_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'bdi_tabela_estados',
    path: '/estados',
    itemsKey: 'estados',
    icon: Icons.flag_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'bdi_tabela_tipos_ideia',
    path: '/tipos-ideia',
    itemsKey: 'tipoIdeias',
    icon: Icons.lightbulb_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'bdi_tabela_tipos_ideia_usuario',
    path: '/tipos-ideia-usuario',
    itemsKey: 'tipoIdeiaUsuarios',
    icon: Icons.person_pin_rounded,
    fields: [nomeField],
  ),
  CrudTable(
    title: 'bdi_tabela_perfis',
    path: '/perfis',
    itemsKey: 'perfils',
    icon: Icons.admin_panel_settings_rounded,
    fields: [
      nomeField,
      CrudField(
        name: 'descricao',
        label: 'bdi_descricao',
        type: CrudFieldType.multiline,
        required: false,
      ),
    ],
    subtitleFields: [CrudDisplayField('bdi_descricao', 'descricao')],
  ),
  CrudTable(
    title: 'bdi_tabela_permissoes',
    path: '/permissoes',
    itemsKey: 'permissaos',
    icon: Icons.lock_rounded,
    fields: [
      CrudField(name: 'recurso', label: 'bdi_campo_recurso'),
      CrudField(name: 'acao', label: 'bdi_campo_acao'),
      CrudField(
        name: 'descricao',
        label: 'bdi_descricao',
        type: CrudFieldType.multiline,
        required: false,
      ),
    ],
    titlePaths: ['recurso', 'acao'],
    subtitleFields: [CrudDisplayField('bdi_descricao', 'descricao')],
  ),
  CrudTable(
    title: 'bdi_tabela_permissoes_perfil',
    path: '/perfil-permissoes',
    itemsKey: 'perfilPermissaos',
    icon: Icons.rule_rounded,
    keyPaths: ['perfil.id', 'permissao.id'],
    fields: [
      CrudField(
        name: 'perfilId',
        label: 'bdi_perfil',
        type: CrudFieldType.select,
        recordPath: 'perfil.id',
        optionsPath: '/perfis',
        optionsItemsKey: 'perfils',
      ),
      CrudField(
        name: 'permissaoId',
        label: 'bdi_campo_permissao',
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
    title: 'bdi_tabela_ideias',
    path: '/ideias',
    itemsKey: 'ideias',
    icon: Icons.tips_and_updates_rounded,
    fields: [
      CrudField(name: 'titulo', label: 'titulo'),
      CrudField(
        name: 'descricao',
        label: 'bdi_descricao',
        type: CrudFieldType.multiline,
      ),
      CrudField(
        name: 'estadoId',
        label: 'estado',
        type: CrudFieldType.select,
        recordPath: 'estado.id',
        optionsPath: '/estados',
        optionsItemsKey: 'estados',
      ),
      CrudField(
        name: 'tipoId',
        label: 'bdi_campo_tipo_ideia',
        type: CrudFieldType.select,
        recordPath: 'tipo.id',
        optionsPath: '/tipos-ideia',
        optionsItemsKey: 'tipoIdeias',
      ),
    ],
    titlePaths: ['titulo'],
    subtitleFields: [
      CrudDisplayField('estado', 'estado.nome'),
      CrudDisplayField('tipo', 'tipo.nome'),
      CrudDisplayField('bdi_descricao', 'descricao'),
    ],
  ),
  CrudTable(
    title: 'bdi_tabela_categorias_ideias',
    path: '/ideia-categorias',
    itemsKey: 'ideiaCategorias',
    icon: Icons.account_tree_rounded,
    keyPaths: ['ideia.id', 'categoria.id'],
    fields: [
      CrudField(
        name: 'ideiaId',
        label: 'bdi_campo_ideia',
        type: CrudFieldType.select,
        recordPath: 'ideia.id',
        optionsPath: '/ideias',
        optionsItemsKey: 'ideias',
        optionLabelPaths: ['titulo'],
      ),
      CrudField(
        name: 'categoriaId',
        label: 'bdi_categoria',
        type: CrudFieldType.select,
        recordPath: 'categoria.id',
        optionsPath: '/categorias',
        optionsItemsKey: 'categorias',
      ),
    ],
    titlePaths: ['ideia.titulo', 'categoria.nome'],
  ),
  CrudTable(
    title: 'bdi_tabela_usuarios_ideias',
    path: '/ideia-usuarios',
    itemsKey: 'ideiaUsuarios',
    icon: Icons.groups_rounded,
    keyPaths: ['ideia.id', 'usuario.id'],
    fields: [
      CrudField(
        name: 'ideiaId',
        label: 'bdi_campo_ideia',
        type: CrudFieldType.select,
        recordPath: 'ideia.id',
        optionsPath: '/ideias',
        optionsItemsKey: 'ideias',
        optionLabelPaths: ['titulo'],
      ),
      CrudField(
        name: 'usuarioId',
        label: 'usuario',
        type: CrudFieldType.select,
        recordPath: 'usuario.id',
        optionsPath: '/usuarios',
        optionsItemsKey: 'usuarios',
        optionLabelPaths: ['nome', 'email'],
      ),
      CrudField(
        name: 'tipoIdeiaUsuarioId',
        label: 'bdi_campo_tipo_usuario_ideia',
        type: CrudFieldType.select,
        recordPath: 'tipoIdeiaUsuario.id',
        optionsPath: '/tipos-ideia-usuario',
        optionsItemsKey: 'tipoIdeiaUsuarios',
      ),
    ],
    titlePaths: ['ideia.titulo', 'usuario.nome'],
    subtitleFields: [
      CrudDisplayField('email', 'usuario.email'),
      CrudDisplayField('tipo', 'tipoIdeiaUsuario.nome'),
    ],
  ),
  CrudTable(
    title: 'bdi_tabela_usuarios',
    path: '/usuarios',
    itemsKey: 'usuarios',
    icon: Icons.person_rounded,
    fields: [
      CrudField(
        name: 'uidFirebase',
        label: 'bdi_campo_uid_firebase',
        required: false,
      ),
      nomeField,
      CrudField(name: 'email', label: 'email'),
      CrudField(
        name: 'perfilId',
        label: 'bdi_perfil',
        type: CrudFieldType.select,
        required: false,
        recordPath: 'perfil.id',
        optionsPath: '/perfis',
        optionsItemsKey: 'perfils',
      ),
      CrudField(
        name: 'departamentoId',
        label: 'departamento',
        type: CrudFieldType.select,
        required: false,
        recordPath: 'departamento.id',
        optionsPath: '/departamentos',
        optionsItemsKey: 'departamentos',
      ),
      CrudField(
        name: 'cursoId',
        label: 'curso',
        type: CrudFieldType.select,
        required: false,
        recordPath: 'curso.id',
        optionsPath: '/cursos',
        optionsItemsKey: 'cursos',
      ),
    ],
    titlePaths: ['nome'],
    subtitleFields: [
      CrudDisplayField('email', 'email'),
      CrudDisplayField('bdi_perfil', 'perfil.nome'),
    ],
  ),
];
