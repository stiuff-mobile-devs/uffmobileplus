import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/registration/ui/widgets/loading_state.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/registration/ui/widgets/registration_error_state.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/registration/ui/widgets/registration_header.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/registration/ui/widgets/registration_submit_button.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/registration/ui/widgets/registration_text_field.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/registration/ui/widgets/user_type_segment.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/usuario_api_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late final BancoDeIdeiasController _moduleController =
      Get.find<BancoDeIdeiasController>();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  bool _isAluno = true;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _cursoId;
  String? _departamentoId;
  String? _errorMessage;
  List<CrudRecord> _cursos = const [];
  List<CrudRecord> _departamentos = const [];

  @override
  void initState() {
    super.initState();
    _carregarOpcoes();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarOpcoes() async {
    try {
      final opcoes = await _moduleController.usuarioApiService
          .carregarOpcoesCadastro();

      if (!mounted) {
        return;
      }

      setState(() {
        _cursos = opcoes.cursos;
        _departamentos = opcoes.departamentos;
        _cursoId = _cursos.isEmpty ? null : _cursos.first.id;
        _departamentoId = _departamentos.isEmpty
            ? null
            : _departamentos.first.id;
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = err.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _salvarCadastro() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _moduleController.usuarioApiService.cadastrarUsuarioAtual(
        UsuarioCadastroData(
          nome: _nomeController.text.trim(),
          isAluno: _isAluno,
          cursoId: _isAluno ? _cursoId : null,
          departamentoId: _isAluno ? null : _departamentoId,
        ),
      );

      if (!mounted) {
        return;
      }

      _moduleController.reloadUsuario();
    } catch (err) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'bdi_erro_concluir_cadastro'.trParams({'err': err.toString()}),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sair() async {
    await _moduleController.signOut();
  }

  String? _obrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'campo_obrigatorio'.tr;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bdi_completar_cadastro'.tr),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
        actions: [
          IconButton(
            tooltip: 'sair'.tr,
            onPressed: _isSaving ? null : _sair,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_errorMessage != null) {
      return RegistrationErrorState(
        message: _errorMessage!,
        onRetry: _carregarOpcoes,
      );
    }

    return Theme(
      data: _registrationTheme(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              AppColors.mediumBlue(alpha: 36),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const RegistrationHeader(),
              const SizedBox(height: 24),
              RegistrationTextField(
                textController: _nomeController,
                label: 'nome'.tr,
                icon: Icons.person_rounded,
                validator: _obrigatorio,
              ),
              const SizedBox(height: 20),
              UserTypeSegment(
                isAluno: _isAluno,
                enabled: !_isSaving,
                onChanged: (value) => setState(() => _isAluno = value),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isAluno ? _buildAlunoFields() : _buildProfessorFields(),
              ),
              const SizedBox(height: 24),
              RegistrationSubmitButton(
                isSaving: _isSaving,
                onPressed: _salvarCadastro,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _registrationTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white70,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightBlue()),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.lightBlue(),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: base.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.darkBlue()
                : Colors.white;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.lightBlue()
                : Colors.white.withValues(alpha: 0.08);
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: Colors.white.withValues(alpha: 0.20)),
          ),
        ),
      ),
    );
  }

  Widget _buildAlunoFields() {
    return Column(
      key: const ValueKey('aluno-fields'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _cursoId,
          dropdownColor: AppColors.darkBlue(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'curso'.tr,
            prefixIcon: const Icon(Icons.school_rounded),
            border: const OutlineInputBorder(),
          ),
          items: _cursos
              .map(
                (curso) =>
                    DropdownMenuItem(value: curso.id, child: Text(curso.nome)),
              )
              .toList(growable: false),
          onChanged: _isSaving
              ? null
              : (value) => setState(() => _cursoId = value),
          validator: (value) =>
              value == null ? 'bdi_selecione_curso'.tr : null,
        ),
      ],
    );
  }

  Widget _buildProfessorFields() {
    return Column(
      key: const ValueKey('professor-fields'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _departamentoId,
          dropdownColor: AppColors.darkBlue(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'departamento'.tr,
            prefixIcon: const Icon(Icons.business_rounded),
            border: const OutlineInputBorder(),
          ),
          items: _departamentos
              .map(
                (departamento) => DropdownMenuItem(
                  value: departamento.id,
                  child: Text(departamento.nome),
                ),
              )
              .toList(growable: false),
          onChanged: _isSaving
              ? null
              : (value) => setState(() => _departamentoId = value),
          validator: (value) =>
              value == null ? 'bdi_selecione_departamento'.tr : null,
        ),
      ],
    );
  }
}
