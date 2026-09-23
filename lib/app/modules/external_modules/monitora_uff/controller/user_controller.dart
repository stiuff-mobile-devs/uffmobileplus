import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/harpia_claims_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/google_groups_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/google_group_member_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';

class UserController extends GetxController {
  final _user = Rxn<UserModel>();
  UserModel? get user => _user.value;

  String? _googleName;

  final isLoading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await HarpiaClaimsService.ensureClaims();
    await loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      final googleUser = await UserDataRepository().getUserGoogleModel();
      debugPrint('Hive user: ${googleUser?.email} / ${googleUser?.name}');
      _googleName = googleUser?.name;
      final email = googleUser?.email ?? "";

      if (email.isEmpty) {
        _user.value = null;
        return;
      }

      // Tentar carregar do Firestore
      var firestoreUser = await _initializeUser();
      if (firestoreUser != null) {
        _user.value = firestoreUser;
      } else {
        // Criar documento no Firestore APENAS se o usuário for observável.
        // A coleção `usuarios` existe exclusivamente para armazenar
        // coordenadas de observáveis (MEMBER/MANAGER).
        final isObservavel = await HarpiaClaimsService.isObservavel();
        if (isObservavel) {
          try {
            await FirebaseProvider().setUser(UserModel(
              email: email,
              nome: _googleName,
            ));
            _user.value = await _initializeUser();
          } catch (e) {
            debugPrint('[UserController] Erro ao criar doc do usuário: $e');
          }
        } else {
          debugPrint(
            '[UserController] Usuário $email não é observável — doc em `usuarios` não criado.',
          );
        }
      }
    } catch (e) {
      debugPrint('[UserController] Erro ao carregar usuário atual: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel?> _initializeUser() async {
    try {
      final googleUser = await UserDataRepository().getUserGoogleModel();
      final email = googleUser?.email ?? "";
      debugPrint('Email usado no lookup: $email');
      if (email.isEmpty) return null;

      final user = await FirebaseProvider().getUserByEmail(email);
      return user;
    } catch (e) {
      debugPrint('[UserController] Erro ao buscar usuário no Firestore: $e');
      return null;
    }
  }

  bool isTrackable() {
    final googleGroupsCtrl = Get.find<HarpiaGoogleGroupsController>();
    final currentUserEmail = _user.value?.email;

    if (currentUserEmail == null) return false;

    // Procura o usuário logado entre os membros do grupo observado
    final member = googleGroupsCtrl.observedMembers.firstWhereOrNull(
      (m) => m.email == currentUserEmail,
    );

    // Retorna true se for manager ou member (owner não conta como trackable)
    return member?.role == GoogleGroupRole.manager
      || member?.role == GoogleGroupRole.member;
  }

  String getUserName() {
    return user!.nome ??
        _googleName ??
        'nome_nao_informado'.tr;
  }
}