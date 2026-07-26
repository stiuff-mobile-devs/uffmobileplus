import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';
import 'idea_filter_dialog.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/data/idea_filter_models.dart';
import 'idea_filter_widgets.dart';

class IdeaFilterBar extends StatefulWidget {
  const IdeaFilterBar({
    super.key,
    required this.title,
    required this.filtro,
    required this.opcoesFuture,
    required this.onChanged,
  });

  final String title;
  final IdeiaFiltro filtro;
  final Future<IdeiaCadastroOpcoes> opcoesFuture;
  final ValueChanged<IdeiaFiltro> onChanged;

  @override
  State<IdeaFilterBar> createState() => _IdeaFilterBarState();
}

class _IdeaFilterBarState extends State<IdeaFilterBar> {
  late final TextEditingController _tituloController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.filtro.nome);
  }

  @override
  void didUpdateWidget(covariant IdeaFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filtro.nome != widget.filtro.nome &&
        _tituloController.text != widget.filtro.nome) {
      _tituloController.text = widget.filtro.nome;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _abrirFiltros(
    BuildContext context,
    IdeiaCadastroOpcoes opcoes,
  ) async {
    final novoFiltro = await showDialog<IdeiaFiltro>(
      context: context,
      builder: (context) => IdeaFilterDialog(
        filtro: widget.filtro.copyWith(nome: _tituloController.text),
        tipos: opcoes.tipos,
        categorias: opcoes.categorias,
      ),
    );

    if (novoFiltro != null) {
      widget.onChanged(novoFiltro);
    }
  }

  void _buscarPorTitulo() {
    widget.onChanged(widget.filtro.copyWith(nome: _tituloController.text));
  }

  void _limparFiltros() {
    _tituloController.clear();
    widget.onChanged(const IdeiaFiltro());
  }

  void _removerFiltro(IdeaActiveFilter filter) {
    final novoFiltro = switch (filter.type) {
      IdeaActiveFilterType.titulo => widget.filtro.copyWith(nome: ''),
      IdeaActiveFilterType.tipo => widget.filtro.copyWith(tipoId: ''),
      IdeaActiveFilterType.categoria => widget.filtro.copyWith(categoriaId: ''),
    };

    if (filter.type == IdeaActiveFilterType.titulo) {
      _tituloController.clear();
    }

    widget.onChanged(novoFiltro);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<IdeiaCadastroOpcoes>(
      future: widget.opcoesFuture,
      builder: (context, snapshot) {
        final opcoes =
            snapshot.data ??
            const IdeiaCadastroOpcoes(estados: [], tipos: [], categorias: []);
        final filtrosAtivos = _filtrosAtivos(opcoes);
        final hasFiltro = filtrosAtivos.isNotEmpty;

        return Material(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBlue(alpha: 128),
                  AppColors.mediumBlue(alpha: 38),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IdeaFilterSearchRow(
                    textController: _tituloController,
                    canOpenFilters: snapshot.hasData,
                    hasFiltro: hasFiltro,
                    onSearch: _buscarPorTitulo,
                    onOpenFilters: snapshot.hasData
                        ? () => _abrirFiltros(context, opcoes)
                        : null,
                    onClear: hasFiltro ? _limparFiltros : null,
                  ),
                  if (hasFiltro) ...[
                    const SizedBox(height: 10),
                    IdeaActiveFilterChips(
                      filters: filtrosAtivos,
                      onRemove: _removerFiltro,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<IdeaActiveFilter> _filtrosAtivos(IdeiaCadastroOpcoes opcoes) {
    return [
      if (widget.filtro.nome.trim().isNotEmpty)
        IdeaActiveFilter(
          type: IdeaActiveFilterType.titulo,
          label: 'Titulo',
          value: widget.filtro.nome.trim(),
        ),
      if (widget.filtro.tipoId != null && widget.filtro.tipoId!.isNotEmpty)
        IdeaActiveFilter(
          type: IdeaActiveFilterType.tipo,
          label: 'Tipo',
          value: _nomeDaOpcao(opcoes.tipos, widget.filtro.tipoId!),
        ),
      if (widget.filtro.categoriaId != null &&
          widget.filtro.categoriaId!.isNotEmpty)
        IdeaActiveFilter(
          type: IdeaActiveFilterType.categoria,
          label: 'Categoria',
          value: _nomeDaOpcao(opcoes.categorias, widget.filtro.categoriaId!),
        ),
    ];
  }

  String _nomeDaOpcao(List<IdeiaOpcao> opcoes, String id) {
    for (final opcao in opcoes) {
      if (opcao.id == id) {
        return opcao.nome;
      }
    }
    return 'Carregando...';
  }
}

extension on IdeiaFiltro {
  IdeiaFiltro copyWith({String? nome, String? tipoId, String? categoriaId}) {
    return IdeiaFiltro(
      nome: nome ?? this.nome,
      tipoId: tipoId ?? this.tipoId,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }
}
