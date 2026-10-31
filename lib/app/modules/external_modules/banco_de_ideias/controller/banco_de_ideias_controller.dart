import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/registration_draft.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/module_access.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/usuario_atual.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/auth_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/ideia_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/usuario_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/home/ui/widgets/user_destination.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';

class BancoDeIdeiasController extends GetxController {
  BancoDeIdeiasController({
    AuthService? authService,
    CrudApiService? crudApiService,
    IdeiaApiService? ideiaApiService,
    UsuarioApiService? usuarioApiService,
    UserDataRepository? userDataRepository,
  }) : authService = authService ?? Get.find<AuthService>(),
       crudApiService = crudApiService ?? Get.find<CrudApiService>(),
       ideiaApiService = ideiaApiService ?? Get.find<IdeiaApiService>(),
       usuarioApiService = usuarioApiService ?? Get.find<UsuarioApiService>(),
       userDataRepository = userDataRepository ?? UserDataRepository();

  static const accessGroupEmail = 'banco-de-ideias.ic@id.uff.br';
  static final accessRequestUri = Uri.parse(
    'https://sites.google.com/view/bancodeideiasuff/',
  );

  static const destinations = [
    UserDestination(
      labelKey: 'bdi_lista_de_ideias',
      icon: Icons.lightbulb_outline_rounded,
      selectedIcon: Icons.lightbulb_rounded,
    ),
    UserDestination(
      labelKey: 'bdi_minhas_ideias',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    UserDestination(
      labelKey: 'bdi_perfil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  final AuthService authService;
  final CrudApiService crudApiService;
  final IdeiaApiService ideiaApiService;
  final UsuarioApiService usuarioApiService;
  final UserDataRepository userDataRepository;

  Future<UsuarioAtual?>? usuarioFuture;
  RegistrationDraft? registrationDraft;
  CadastroUsuarioOpcoes? registrationOptions;
  Future<ModuleAccess>? accessFuture;
  String? loadedUid;
  int selectedIndex = 0;
  int refreshToken = 0;

  UserDestination get selectedDestination => destinations[selectedIndex];

  bool get mostrarBotaoNovaIdeia => selectedIndex == 0 || selectedIndex == 1;

  Future<ModuleAccess> checkModuleAccess() {
    return accessFuture ??= _loadModuleAccess();
  }

  Future<ModuleAccess> _loadModuleAccess({
    bool forceGoogleLogin = false,
  }) async {
    var user = (await userDataRepository.getUserData()) ?? UserData();
    if (isClosed) return ModuleAccess.googleLoginRequired;
    var email = user.userGoogleModel?.email;
    var refreshGroups = user.gdiGroupsGoogle?.lastUpdate == null;

    if (forceGoogleLogin || !await authService.hasValidGoogleSession(email)) {
      // Groups left by a previous account must never authorize the new login.
      final cleared = await userDataRepository.updateGdiGroupsGoogle(
        GdiGroupsGoogle(null, []),
      );
      if (cleared != 'success') throw StateError(cleared);
      if (isClosed) return ModuleAccess.googleLoginRequired;

      final googleUser = await authService.signInGoogle();
      if (isClosed || googleUser == null) {
        return ModuleAccess.googleLoginRequired;
      }
      if (!await authService.hasValidGoogleSession(googleUser.email)) {
        return ModuleAccess.googleLoginRequired;
      }
      final saved = await userDataRepository.saveUserGoogleModel(googleUser);
      if (saved != 'success') throw StateError(saved);
      email = googleUser.email;
      refreshGroups = true;
    }

    if (refreshGroups) {
      final token = await authService.getAppIdToken();
      if (token == null || token.isEmpty) {
        return ModuleAccess.googleLoginRequired;
      }
      final groups = await userDataRepository.getGdiGroupsGoogle(token, email!);
      final updated = await userDataRepository.updateGdiGroupsGoogle(groups);
      if (updated != 'success') throw StateError(updated);
      user = (await userDataRepository.getUserData()) ?? UserData();
    }
    final googleGroups = user.gdiGroupsGoogle?.gdiGroups ?? <GdiGroups>[];

    return googleGroups.any(
          (group) => group.email?.trim().toLowerCase() == accessGroupEmail,
        )
        ? ModuleAccess.allowed
        : ModuleAccess.denied;
  }

  void prepareLoggedUser(String uid) {
    if (loadedUid == uid && usuarioFuture != null) {
      return;
    }

    loadedUid = uid;
    registrationDraft = null;
    registrationOptions = null;
    usuarioFuture = _carregarOuCadastrarUsuario();
  }

  Future<UsuarioAtual?> _carregarOuCadastrarUsuario() async {
    final usuario = await usuarioApiService.carregarUsuarioAtual();
    if (usuario != null) {
      if (usuario.raw['tipoUsuario'] == null ||
          usuario.raw['tipoUsuario'].toString().trim().isEmpty) {
        try {
          final external = Get.find<ExternalModulesServices>();
          await external.initialize();
          final draft = RegistrationDraft.fromExternalData(
            nome: '',
            vinculo: external.getUserBond(),
            curso: '',
            opcoes: const CadastroUsuarioOpcoes(cursos: [], departamentos: []),
          );
          await usuarioApiService.preencherVinculo(draft.tipoUsuario);
          return await usuarioApiService.carregarUsuarioAtual() ?? usuario;
        } catch (err) {
          // A transient failure must not interrupt access by an existing user.
          debugPrint('Falha ao completar vinculo silenciosamente: $err');
        }
      }
      return usuario;
    }

    final external = Get.find<ExternalModulesServices>();
    await external.initialize();
    final opcoes = await usuarioApiService.carregarOpcoesCadastro();
    final cursoNome = external.getUserCourse().trim();
    final curso = cursoNome.isEmpty
        ? null
        : await usuarioApiService.prepararCurso(cursoNome);
    final cursos = [...opcoes.cursos];
    if (curso != null) {
      cursos.removeWhere((item) => item.id == curso.id);
      cursos.add(curso);
    }
    registrationOptions = CadastroUsuarioOpcoes(
      cursos: cursos,
      departamentos: const [],
    );
    final nome = external.getUserName()?.trim() ?? '';
    final identificado = RegistrationDraft.fromExternalData(
      nome: nome.isNotEmpty ? nome : external.getUserNameGoogle() ?? '',
      vinculo: external.getUserBond(),
      curso: external.getUserCourse(),
      opcoes: registrationOptions!,
    );
    final draft = RegistrationDraft(
      nome: identificado.nome,
      isAluno: identificado.isAluno,
      cursoId: identificado.isAluno == true
          ? curso?.id ?? identificado.cursoId
          : null,
    );
    registrationDraft = draft;
    final cadastro = draft.cadastroCompleto;
    if (cadastro == null) return null;

    await usuarioApiService.cadastrarUsuarioAtual(cadastro);
    final cadastrado = await usuarioApiService.carregarUsuarioAtual();
    if (cadastrado == null) {
      throw StateError('bdi_nao_foi_possivel_carregar_usuario'.tr);
    }
    return cadastrado;
  }

  void reloadUsuario() {
    usuarioFuture = _carregarOuCadastrarUsuario();
    update();
  }

  void selectDestination(int index, {bool closeDrawer = false}) {
    selectedIndex = index;
    update();

    if (closeDrawer) {
      Get.back();
    }
  }

  void recarregarIdeias() {
    refreshToken++;
    update();
  }

  void voltarParaAreaUsuario() {
    selectedIndex = 0;
    update();
  }

  Future<void> signOut() async {
    await authService.signOut();
    accessFuture = null;
    loadedUid = null;
    usuarioFuture = null;
    selectedIndex = 0;
    update();
  }

  void retryModuleAccess() {
    accessFuture = null;
    update();
  }

  void goToLogin() {
    accessFuture = _loadModuleAccess(forceGoogleLogin: true);
    update();
  }

  Future<void> solicitarAcesso() async {
    try {
      final opened = await launchUrl(
        accessRequestUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (_) {
      // Keep the access notice available if the browser cannot be opened.
    }
    if (!isClosed) {
      Get.snackbar('bdi_acesso_restrito'.tr, 'bdi_solicitar_acesso_erro'.tr);
    }
  }
}
