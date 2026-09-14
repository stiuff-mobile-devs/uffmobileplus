import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Serviço centralizado para sincronização e validação dos Custom Claims
/// do Harpia (`harpia_roles`).
class HarpiaClaimsService {
  HarpiaClaimsService._();

  static const String _harpiaAppName = 'harpia';
  static const String _uffMobileAppName = 'uffmobileplus';
  static const String _region = 'us-central1';

  static fb.FirebaseAuth get _harpiaAuth =>
      fb.FirebaseAuth.instanceFor(app: Firebase.app(_harpiaAppName));

  static fb.FirebaseAuth get _uffMobileAuth =>
      fb.FirebaseAuth.instanceFor(app: Firebase.app(_uffMobileAppName));

  /// Sincroniza os Custom Claims chamando a Cloud Function `syncHarpiaClaims`.
  ///
  /// 1. Obtém o ID token fresco do app `uffmobileplus` (necessário para autenticar
  ///    na API intermediária de grupos da UFF que autoriza o projeto uff-mobile-plus).
  /// 2. Invoca a Cloud Function `syncHarpiaClaims` no Firebase do Harpia (`harpia-c699b`).
  /// 3. Força refresh do token no Firebase Auth do Harpia para incorporar os novos claims.
  ///
  /// Retorna o mapa de roles retornado pela Cloud Function, ou `null` em caso de erro.
  static Future<Map<String, dynamic>?> syncClaims() async {
    try {
      final harpiaUser = _harpiaAuth.currentUser;
      if (harpiaUser == null) {
        debugPrint('[HarpiaClaimsService] Usuário Harpia não autenticado.');
        return null;
      }

      // 1. Obter o idToken do uffmobileplus para repassar ao backend de grupos
      final uffUser = _uffMobileAuth.currentUser;
      final rawToken = await (uffUser ?? harpiaUser).getIdToken(true);
      if (rawToken == null) {
        debugPrint('[HarpiaClaimsService] Token nulo.');
        return null;
      }

      // 2. Chamar a Cloud Function no projeto Harpia
      final functions = FirebaseFunctions.instanceFor(
        app: Firebase.app(_harpiaAppName),
        region: _region,
      );
      final callable = functions.httpsCallable('syncHarpiaClaims');
      final result = await callable.call({'idToken': rawToken});

      // 3. Forçar refresh no Firebase Harpia para incorporar os novos claims
      await harpiaUser.getIdToken(true);

      final data = result.data as Map<String, dynamic>?;
      final roles = data?['harpia_roles'];
      debugPrint('[HarpiaClaimsService] Claims sincronizados com sucesso: $roles');
      return roles is Map<String, dynamic> ? roles : null;
    } catch (e) {
      debugPrint('[HarpiaClaimsService] Erro ao sincronizar claims: $e');
      return null;
    }
  }

  /// Lê os custom claims `harpia_roles` do token atual do Harpia
  /// SEM forçar sincronização com a Cloud Function.
  ///
  /// Retorna o mapa de roles ou `null` se ausente.
  static Future<Map<String, dynamic>?> readClaims({bool forceRefresh = false}) async {
    try {
      final harpiaUser = _harpiaAuth.currentUser;
      if (harpiaUser == null) return null;

      final idTokenResult = await harpiaUser.getIdTokenResult(forceRefresh);
      final claims = idTokenResult.claims;
      if (claims == null) {
        debugPrint('[HarpiaClaimsService] Token sem claims.');
        return null;
      }

      final harpiaRoles = claims['harpia_roles'];
      debugPrint('[HarpiaClaimsService] Claims lidos do token: $harpiaRoles');

      if (harpiaRoles == null || harpiaRoles is! Map) return null;
      return Map<String, dynamic>.from(harpiaRoles);
    } catch (e) {
      debugPrint('[HarpiaClaimsService] Erro ao ler claims: $e');
      return null;
    }
  }

  /// Verifica se o token atual contém papel em pelo menos um grupo (isAutorizado).
  static Future<bool> isAutorizado() async {
    final roles = await readClaims();
    return roles != null && roles.isNotEmpty;
  }

  /// Verifica se o token atual contém claims de observável (MEMBER ou
  /// MANAGER em pelo menos um grupo).
  static Future<bool> isObservavel() async {
    final roles = await readClaims();
    if (roles == null || roles.isEmpty) return false;
    return roles.values.any(
      (role) => role == 'MEMBER' || role == 'MANAGER',
    );
  }

  /// Garante que os custom claims estejam presentes e válidos.
  ///
  /// 1. Lê os claims atuais.
  /// 2. Se já forem válidos (contêm MEMBER/MANAGER), retorna `true`.
  /// 3. Se não, tenta sincronizar via Cloud Function.
  /// 4. Após sincronização, valida novamente.
  ///
  /// Retorna `true` se os claims estão válidos, `false` caso contrário.
  static Future<bool> ensureClaims() async {
    // 1. Tentar ler os claims existentes no token
    final existingRoles = await readClaims();
    if (existingRoles != null && existingRoles.isNotEmpty) {
      final hasObservableRole = existingRoles.values.any(
        (role) => role == 'MEMBER' || role == 'MANAGER',
      );
      if (hasObservableRole) {
        debugPrint('[HarpiaClaimsService] Claims já válidos no token: $existingRoles');
        return true;
      }
    }

    // 2. Sincronizar via Cloud Function
    debugPrint('[HarpiaClaimsService] Sincronizando claims via Cloud Function...');
    final syncedRoles = await syncClaims();

    if (syncedRoles == null || syncedRoles.isEmpty) {
      debugPrint('[HarpiaClaimsService] Sincronização retornou vazio ou falhou.');
      return false;
    }

    final hasObservableRole = syncedRoles.values.any(
      (role) => role == 'MEMBER' || role == 'MANAGER',
    );

    if (!hasObservableRole) {
      debugPrint(
        '[HarpiaClaimsService] Usuário tem grupos, mas nenhum observável (MEMBER/MANAGER): $syncedRoles',
      );
    }

    return hasObservableRole;
  }
}
