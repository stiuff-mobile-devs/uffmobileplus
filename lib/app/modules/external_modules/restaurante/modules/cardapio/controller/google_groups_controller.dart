import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/connections/google_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/google_group_member_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/google_group_model.dart';

class GoogleGroupsController extends GetxController {
  final GoogleService _googleService = GoogleService();
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instanceFor(
      app: Firebase.app('uffmobileplus')
  );

  final RxString _loadError = RxString('');
  RxString get loadError => _loadError;

  static String get rootGroupEmail => "administradores-cardapio.proaes@id.uff.br";

  /// Indica se o usuário é administrador (membro do grupo)
  final Rx<bool?> isAdmin = Rx<bool?>(null);

  /// Indica se o carregamento dos grupos já foi concluído.
  final RxBool isLoading = RxBool(true);

  @override
  void onInit() {
    super.onInit();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    _loadError.value = '';
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _loadError.value = 'not_authenticated';
        debugPrint("Usuário não autenticado.");
        isLoading.value = false;
        return;
      }

      final token = await user.getIdToken(true);
      if (token == null) {
        _loadError.value = 'no_token';
        debugPrint("Token não disponível.");
        isLoading.value = false;
        return;
      }

      final userEmail = user.email;
      if (userEmail == null) {
        debugPrint("Email do usuário não disponível.");
        _loadError.value = 'no_email';
        isLoading.value = false;
        return;
      }

      final entities = await _googleService.getGroupEntities(token, rootGroupEmail);
      final isMember = entities.any(
              (m) => m['email']?.toString().trim().toLowerCase() == userEmail.trim().toLowerCase()
      );

      isAdmin.value = isMember;
    } catch(e, stack) {
      debugPrint('$e\n$stack');
      _loadError.value = '$e';
      isAdmin.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}