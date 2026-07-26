import 'package:flutter/material.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/ideia_api_service.dart';
import 'idea_form_widgets.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_state_widgets.dart';

class IdeaCreateDialog extends StatefulWidget {
  const IdeaCreateDialog({
    super.key,
    required this.ideiaApiService,
    this.detalhe,
  });

  final IdeiaApiService ideiaApiService;
  final IdeiaDetalhe? detalhe;

  @override
  State<IdeaCreateDialog> createState() => _IdeaCreateDialogState();
}

class _IdeaCreateDialogState extends State<IdeaCreateDialog> {
  static const _totalEtapasCadastro = 5;

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  late Future<IdeiaCadastroOpcoes> _opcoesFuture;
  String? _estadoId;
  String? _tipoId;
  final Set<String> _categoriaIds = {};
  int _etapaCadastro = 0;
  bool _salvando = false;

  bool get _isEdit => widget.detalhe != null;
  bool get _ultimaEtapaCadastro => _etapaCadastro == _totalEtapasCadastro - 1;

  String get _tituloEtapaCadastro {
    return switch (_etapaCadastro) {
      0 => 'Titulo',
      1 => 'Descricao',
      2 => 'Tipo',
      3 => 'Estado',
      _ => 'Categorias',
    };
  }

  @override
  void initState() {
    super.initState();
    final detalhe = widget.detalhe;
    if (detalhe != null) {
      final ideia = detalhe.resumo;
      _tituloController.text = ideia.titulo;
      _descricaoController.text = ideia.descricao;
      _estadoId = _idDe(ideia.raw['estado']);
      _tipoId = _idDe(ideia.raw['tipo']);
      _categoriaIds.addAll(detalhe.categorias.map((categoria) => categoria.id));
    }
    _opcoesFuture = widget.ideiaApiService.carregarOpcoesCadastro();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando || !_formularioValidoParaSalvar()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      final data = IdeiaCadastroData(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        estadoId: _estadoId ?? '',
        tipoId: _tipoId ?? '',
        categoriaIds: _categoriaIds.toList(growable: false),
      );

      final detalhe = widget.detalhe;
      if (detalhe == null) {
        await widget.ideiaApiService.cadastrarMinhaIdeia(data);
      } else {
        await widget.ideiaApiService.atualizarMinhaIdeia(
          detalhe.resumo.id,
          data,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _salvando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  bool _formularioValidoParaSalvar() {
    final formularioAtualValido = _formKey.currentState?.validate() ?? false;
    if (!formularioAtualValido) {
      return false;
    }

    if (_isEdit) {
      return true;
    }

    return _tituloController.text.trim().isNotEmpty &&
        _descricaoController.text.trim().isNotEmpty &&
        (_tipoId?.isNotEmpty ?? false) &&
        (_estadoId?.isNotEmpty ?? false) &&
        _categoriaIds.isNotEmpty;
  }

  void _continuarCadastro() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _etapaCadastro++);
  }

  void _recarregarOpcoesCadastro() {
    setState(() {
      _opcoesFuture = widget.ideiaApiService.carregarOpcoesCadastro();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Editar ideia' : _tituloEtapaCadastro),
      content: SizedBox(
        width: 520,
        child: FutureBuilder<IdeiaCadastroOpcoes>(
          future: _opcoesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return DialogError(
                error: snapshot.error,
                onRetry: _recarregarOpcoesCadastro,
              );
            }

            final opcoes = snapshot.data;
            final estados = opcoes?.estados ?? const [];
            final tipos = opcoes?.tipos ?? const [];
            final categorias = opcoes?.categorias ?? const [];

            return _isEdit
                ? _buildFormularioEdicao(
                    estados: estados,
                    tipos: tipos,
                    categorias: categorias,
                  )
                : _buildFormularioCadastro(
                    estados: estados,
                    tipos: tipos,
                    categorias: categorias,
                  );
          },
        ),
      ),
      actions: _isEdit ? _buildAcoesEdicao() : _buildAcoesCadastro(),
    );
  }

  Widget _buildForm(Widget child) {
    return IdeaFormScrollView(formKey: _formKey, child: child);
  }

  Widget _buildFormularioCadastro({
    required List<IdeiaOpcao> estados,
    required List<IdeiaOpcao> tipos,
    required List<IdeiaOpcao> categorias,
  }) {
    return _buildForm(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IdeaStepProgress(
            currentStep: _etapaCadastro + 1,
            totalSteps: _totalEtapasCadastro,
          ),
          const SizedBox(height: 18),
          _buildCampoEtapaCadastro(
            estados: estados,
            tipos: tipos,
            categorias: categorias,
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioEdicao({
    required List<IdeiaOpcao> estados,
    required List<IdeiaOpcao> tipos,
    required List<IdeiaOpcao> categorias,
  }) {
    return _buildForm(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCampoTitulo(),
          const SizedBox(height: 12),
          _buildCampoDescricao(minLines: 3, maxLines: 5),
          const SizedBox(height: 12),
          _buildCampoTipo(tipos),
          const SizedBox(height: 12),
          _buildCampoEstado(estados),
          const SizedBox(height: 12),
          _buildCampoCategorias(categorias),
        ],
      ),
    );
  }

  Widget _buildCampoEtapaCadastro({
    required List<IdeiaOpcao> estados,
    required List<IdeiaOpcao> tipos,
    required List<IdeiaOpcao> categorias,
  }) {
    return switch (_etapaCadastro) {
      0 => _buildCampoTitulo(
        autofocus: true,
        onFieldSubmitted: (_) => _continuarCadastro(),
      ),
      1 => _buildCampoDescricao(autofocus: true, minLines: 4, maxLines: 6),
      2 => _buildCampoTipo(tipos),
      3 => _buildCampoEstado(estados),
      _ => _buildCampoCategorias(categorias),
    };
  }

  Widget _buildCampoTitulo({
    bool autofocus = false,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return IdeaTextField(
      textController: _tituloController,
      autofocus: autofocus,
      labelText: 'Titulo',
      textInputAction: TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      validator: _validarTitulo,
    );
  }

  Widget _buildCampoDescricao({
    bool autofocus = false,
    required int minLines,
    required int maxLines,
  }) {
    return IdeaTextField(
      textController: _descricaoController,
      autofocus: autofocus,
      labelText: 'Descricao',
      minLines: minLines,
      maxLines: maxLines,
      validator: _validarDescricao,
    );
  }

  Widget _buildCampoTipo(List<IdeiaOpcao> tipos) {
    return _buildDropdownOpcoes(
      labelText: 'Tipo',
      value: _tipoId,
      options: tipos,
      onChanged: (value) => setState(() => _tipoId = value),
      emptyError: 'Selecione o tipo.',
    );
  }

  Widget _buildCampoEstado(List<IdeiaOpcao> estados) {
    return _buildDropdownOpcoes(
      labelText: 'Estado',
      value: _estadoId,
      options: estados,
      onChanged: (value) => setState(() => _estadoId = value),
      emptyError: 'Selecione o estado.',
    );
  }

  Widget _buildDropdownOpcoes({
    required String labelText,
    required String? value,
    required List<IdeiaOpcao> options,
    required ValueChanged<String?> onChanged,
    required String emptyError,
  }) {
    return IdeaOptionsDropdown(
      labelText: labelText,
      value: value,
      options: options,
      onChanged: _salvando ? null : onChanged,
      validator: (value) => _validarSelecao(value, emptyError),
    );
  }

  Widget _buildCampoCategorias(List<IdeiaOpcao> categorias) {
    return IdeaCategoriesField(
      categorias: categorias,
      selectedIds: _categoriaIds,
      enabled: !_salvando,
      onChanged: _atualizarCategoria,
      validator: (_) =>
          _categoriaIds.isEmpty ? 'Selecione pelo menos uma categoria.' : null,
    );
  }

  void _atualizarCategoria({
    required FormFieldState<Set<String>> field,
    required String categoriaId,
    required bool checked,
  }) {
    setState(() {
      if (checked) {
        _categoriaIds.add(categoriaId);
      } else {
        _categoriaIds.remove(categoriaId);
      }
      field.didChange(Set<String>.from(_categoriaIds));
    });
  }

  List<Widget> _buildAcoesEdicao() {
    return [
      _buildBotaoDescartar('Cancelar'),
      _buildBotaoPrincipal(
        onPressed: _salvar,
        icon: Icons.save_rounded,
        label: 'Salvar',
      ),
    ];
  }

  List<Widget> _buildAcoesCadastro() {
    return [
      _buildBotaoDescartar('Descartar', destructive: true),
      _buildBotaoPrincipal(
        onPressed: _ultimaEtapaCadastro ? _salvar : _continuarCadastro,
        icon: _ultimaEtapaCadastro
            ? Icons.save_rounded
            : Icons.arrow_forward_rounded,
        label: _ultimaEtapaCadastro ? 'Salvar' : 'Continuar',
      ),
    ];
  }

  Widget _buildBotaoDescartar(String label, {bool destructive = false}) {
    return IdeaDialogSecondaryButton(
      label: label,
      enabled: !_salvando,
      destructive: destructive,
      onPressed: () => Navigator.of(context).pop(false),
    );
  }

  Widget _buildBotaoPrincipal({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return IdeaDialogPrimaryButton(
      label: label,
      icon: icon,
      loading: _salvando,
      onPressed: onPressed,
    );
  }

  String? _validarTitulo(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Informe o titulo.';
    }
    return null;
  }

  String? _validarDescricao(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Informe a descricao.';
    }
    return null;
  }

  String? _validarSelecao(String? value, String emptyError) {
    if (value == null || value.isEmpty) {
      return emptyError;
    }
    return null;
  }

  String? _idDe(dynamic value) {
    if (value is Map) {
      return value['id']?.toString();
    }
    return null;
  }
}
