import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/usuario_atual.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/ideia_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/usuario_api_service.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_create_dialog.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_detail_dialog.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_filter_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_list.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/profile/ui/widgets/profile_content.dart';
import 'user_destination.dart';

class UserHomeContent extends StatefulWidget {
  const UserHomeContent({
    super.key,
    required this.destination,
    required this.ideiaApiService,
    required this.usuarioApiService,
    required this.refreshToken,
    required this.onOpenAdminPanel,
    required this.onSignOut,
  });

  final UserDestination destination;
  final IdeiaApiService ideiaApiService;
  final UsuarioApiService usuarioApiService;
  final int refreshToken;
  final VoidCallback onOpenAdminPanel;
  final VoidCallback onSignOut;

  @override
  State<UserHomeContent> createState() => _UserHomeContentState();
}

class _UserHomeContentState extends State<UserHomeContent> {
  late Future<List<IdeiaResumo>> _ideiasFuture;
  late Future<List<IdeiaResumo>> _minhasIdeiasFuture;
  late Future<UsuarioAtual?> _usuarioFuture;
  late Future<IdeiaCadastroOpcoes> _opcoesFuture;
  IdeiaFiltro _filtro = const IdeiaFiltro();

  bool get _isPerfil => widget.destination.label == 'Perfil';
  bool get _isMinhasIdeias => widget.destination.label == 'Minhas Ideias';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void didUpdateWidget(covariant UserHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _carregarDados();
    }
  }

  void _carregarDados() {
    _ideiasFuture = widget.ideiaApiService.listarIdeias(filtro: _filtro);
    _minhasIdeiasFuture = widget.ideiaApiService.listarMinhasIdeias(
      filtro: _filtro,
    );
    _usuarioFuture = widget.usuarioApiService.carregarUsuarioAtual();
    _opcoesFuture = widget.ideiaApiService.carregarOpcoesCadastro();
  }

  void _recarregar() {
    setState(_carregarDados);
  }

  void _aplicarFiltro(IdeiaFiltro filtro) {
    setState(() {
      _filtro = filtro;
      _carregarDados();
    });
  }

  Future<void> _abrirDetalheIdeia(IdeiaResumo ideia) {
    return showDialog<void>(
      context: context,
      builder: (context) => IdeaDetailDialog(
        ideiaId: ideia.id,
        ideiaApiService: widget.ideiaApiService,
        onEditIdea: _editarIdeia,
        onDeleteIdea: _confirmarRemocaoIdeia,
        onToggleFavorite: _alternarFavorito,
      ),
    );
  }

  Future<bool> _alternarFavorito(IdeiaResumo ideia) async {
    try {
      if (ideia.favorita) {
        await widget.ideiaApiService.removerFavoritoIdeia(ideia.id);
      } else {
        await widget.ideiaApiService.favoritarIdeia(ideia.id);
      }

      if (!mounted) {
        return false;
      }

      _recarregar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ideia.favorita
                ? 'Ideia removida dos favoritos.'
                : 'Ideia favoritada com sucesso.',
          ),
        ),
      );
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return false;
    }
  }

  Future<bool> _editarIdeia(IdeiaDetalhe detalhe) async {
    final editou = await showDialog<bool>(
      context: context,
      builder: (context) => IdeaCreateDialog(
        ideiaApiService: widget.ideiaApiService,
        detalhe: detalhe,
      ),
    );

    if (editou != true || !mounted) {
      return false;
    }

    _recarregar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ideia atualizada com sucesso.')),
    );
    return true;
  }

  Future<bool> _confirmarRemocaoIdeia(IdeiaResumo ideia) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir ideia'),
        content: Text('Deseja excluir "${ideia.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) {
      return false;
    }

    try {
      await widget.ideiaApiService.removerMinhaIdeia(ideia.id);

      if (!mounted) {
        return false;
      }

      _recarregar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ideia excluida com sucesso.')),
      );
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    if (_isPerfil) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserHomeHeader(destination: destination),
          const SizedBox(height: 18),
          ProfileContent(
            future: _usuarioFuture,
            onRetry: _recarregar,
            onOpenAdminPanel: widget.onOpenAdminPanel,
            onSignOut: widget.onSignOut,
          ),
        ],
      );
    }

    final filterBar = IdeaFilterBar(
      title: destination.label,
      filtro: _filtro,
      opcoesFuture: _opcoesFuture,
      onChanged: _aplicarFiltro,
    );
    final ideaList = IdeaList(
      future: _isMinhasIdeias ? _minhasIdeiasFuture : _ideiasFuture,
      canDelete: _isMinhasIdeias,
      emptyMessage: _isMinhasIdeias
          ? 'Voce ainda nao possui ideias vinculadas.'
          : 'Nenhuma ideia cadastrada.',
      onRetry: _recarregar,
      onOpenIdea: _abrirDetalheIdeia,
      onDeleteIdea: _confirmarRemocaoIdeia,
      onToggleFavorite: _alternarFavorito,
      expand: !isMobile,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserHomeHeader(destination: destination),
          const SizedBox(height: 12),
          filterBar,
          const SizedBox(height: 12),
          Expanded(child: ideaList),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UserHomeHeader(destination: destination),
        const SizedBox(height: 18),
        filterBar,
        const SizedBox(height: 14),
        ideaList,
      ],
    );
  }
}

class _UserHomeHeader extends GetView<BancoDeIdeiasController> {
  const _UserHomeHeader({required this.destination});

  final UserDestination destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.lightBlue(alpha: 46),
          foregroundColor: Colors.white,
          child: Icon(destination.selectedIcon),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            destination.label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
