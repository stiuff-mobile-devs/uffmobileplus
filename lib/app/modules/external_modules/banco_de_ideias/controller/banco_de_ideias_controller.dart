import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/usuario_atual.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/auth_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/ideia_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/usuario_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/home/ui/widgets/user_destination.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

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
  Future<bool>? accessFuture;
  String? loadedUid;
  int selectedIndex = 0;
  int refreshToken = 0;

  UserDestination get selectedDestination => destinations[selectedIndex];

  bool get mostrarBotaoNovaIdeia => selectedIndex == 0 || selectedIndex == 1;

  Future<bool> checkModuleAccess() {
    return accessFuture ??= _loadModuleAccess();
  }

  Future<bool> _loadModuleAccess() async {
    final user = (await userDataRepository.getUserData()) ?? UserData();
    final googleGroups = user.gdiGroupsGoogle?.gdiGroups ?? <GdiGroups>[];

    return googleGroups.any(
      (group) => group.email?.toLowerCase() == accessGroupEmail,
    );
  }

  void prepareLoggedUser(String uid) {
    if (loadedUid == uid && usuarioFuture != null) {
      return;
    }

    loadedUid = uid;
    usuarioFuture = usuarioApiService.carregarUsuarioAtual();
  }

  void reloadUsuario() {
    usuarioFuture = usuarioApiService.carregarUsuarioAtual();
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
    loadedUid = null;
    usuarioFuture = null;
    selectedIndex = 0;
    update();
  }

  void goToLogin() {
    Get.offNamed(Routes.LOGIN);
  }
}
