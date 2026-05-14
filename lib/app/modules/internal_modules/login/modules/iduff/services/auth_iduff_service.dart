import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/utils/auth_client.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_iduff_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_iduff_repository.dart';
import 'package:uffmobileplus/app/utils/errors_mensages.dart';

enum KeycloakEnvironment { homologacao, production }

class OAuth2Info {
  String appId;
  String authUrl;
  String tokenUrl;
  AuthorizationServiceConfiguration authServiceConfig;

  OAuth2Info({
    required this.appId,
    required this.tokenUrl,
    required this.authUrl,
    required this.authServiceConfig,
  });
}

class AuthIduffService {
  final FlutterAppAuth appAuth = FlutterAppAuth();

  UserIduffRepository userIduffRepository = UserIduffRepository();

  AuthenticatedClient? client;

  late KeycloakEnvironment keycloakEnv;
  Map<KeycloakEnvironment, OAuth2Info> keycloakInfo = {
    KeycloakEnvironment.homologacao: OAuth2Info(
      appId: Secrets.homologacaoClientId,
      authUrl: Secrets.homologacaoAuthUrl,
      tokenUrl: Secrets.homologacaoTokenUrl,
      authServiceConfig: const AuthorizationServiceConfiguration(
        authorizationEndpoint: Secrets.homologacaoAuthUrl,
        tokenEndpoint: Secrets.homologacaoTokenUrl,
        endSessionEndpoint: Secrets.homologacaoLogoutUrl,
      ),
    ),
    KeycloakEnvironment.production: OAuth2Info(
      appId: Secrets.productionClientId,
      authUrl: Secrets.productionAuthUrl,
      tokenUrl: Secrets.productionTokenUrl,
      authServiceConfig: const AuthorizationServiceConfiguration(
        authorizationEndpoint: Secrets.productionAuthUrl,
        tokenEndpoint: Secrets.productionTokenUrl,
        endSessionEndpoint: Secrets.productionLogoutUrl,
      ),
    ),
  };

  AuthIduffService() {
    if (kReleaseMode) {
      keycloakEnv = KeycloakEnvironment.production;
    } else {
      keycloakEnv = KeycloakEnvironment.production;
    }
  }

  Future<AuthResult> authenticate(BuildContext? context) async {
    AuthResult authResult = await authorize();
    return authResult;
  }

  Future<AuthResult> authorize() async {
    TokenResponse? tokenResponse;
    AuthorizationResponse? authorizationResponse;
    debugPrint("calling authorize");

    try {

      String? refreshToken = await userIduffRepository.getRefreshToken();

      //Troca o refresh token por um novo access token quando o atual expira, sem precisar fazer login completo novamente.

      if (refreshToken != null) {
        tokenResponse = await _getNewAccessToken(refreshToken);
      }

      //Se nao tiver refresh token, ou se o refresh token ja tiver expirado, faz o login de novo
      if (tokenResponse == null) {
        debugPrint("Primeiro Acesso!");

        authorizationResponse = await _getAuthorization();
        
        if (authorizationResponse == null) {
          return AuthResult(false, ErrorMessage.erro001);
        }

        bool accessTokenTimeOut = false;

        tokenResponse = await _getAccessToken(authorizationResponse).timeout(
          Duration(seconds: 10),
          onTimeout: () {
            accessTokenTimeOut = true;
            return null;
          },
        );
        if (tokenResponse == null) {
          if (accessTokenTimeOut) {
            return AuthResult(
              false,
              "Tempo de autenticação esgotado. Tente novamente mais tarde. Se o problema persistir, entre em contato com o suporte:",
            );
          }
          return AuthResult(false, ErrorMessage.erro002);
        }

        debugPrint("Passou pelo novo acesso");
      }
    } catch (e) {
      debugPrint("error on authorize: $e");
      return AuthResult(false, ErrorMessage.erro003);
    }

    // Essas linhas configuram o sistema para que todas as futuras chamadas às APIs da UFF sejam automaticamente autenticadas
    client = AuthenticatedClient({
      "Authorization": "Bearer ${tokenResponse.accessToken}",
    });

    return _setInfo(tokenResponse, authorizationResponse);
  }

  //Esta função é responsável por iniciar o processo de autenticação OAuth2 com o servidor Keycloak da UFF
  //Abre a tela de login e retorna a resposta de autorização
  Future<AuthorizationResponse?> _getAuthorization() async {
    AuthorizationResponse? authorizationResponse;
    try {
      authorizationResponse = await appAuth.authorize(
        AuthorizationRequest(
          keycloakInfo[keycloakEnv]!.appId,
          Secrets.redirectUri,
          additionalParameters: {"grant_type": "authorization_code"},
          promptValues: ['login'],
          serviceConfiguration: keycloakInfo[keycloakEnv]!.authServiceConfig,
          scopes: Secrets.authScopes,
        ),
      );

      return authorizationResponse;
    } catch (e) {
      debugPrint("Erro no getAuthorization: $e");
    }

    return authorizationResponse;
  }

  // Esta função é responsável por trocar o código de autorização recebido na etapa anterior por tokens de acesso e atualização
  Future<TokenResponse?> _getAccessToken(
    AuthorizationResponse authorizationResponse,
  ) async {
    TokenResponse? tokenResponse;
    try {
      tokenResponse = await appAuth.token(
        TokenRequest(
          keycloakInfo[keycloakEnv]!.appId,
          Secrets.redirectUri,
          authorizationCode: authorizationResponse.authorizationCode,
          codeVerifier: authorizationResponse.codeVerifier,
          nonce: authorizationResponse.nonce,
          serviceConfiguration: keycloakInfo[keycloakEnv]!.authServiceConfig,
          scopes: Secrets.authScopes,
        ),
      );

      return tokenResponse;
    } catch (e) {
      debugPrint("Erro no getAccess: $e");
    }

    return tokenResponse;
  }

  // Esta função tenta renovar o token de acesso usando o token de atualização armazenado
  //Renova automaticamente o access token usando o refresh token salvo, mantendo o usuário logado.
  Future<bool> refreshToken() async {
    TokenResponse? tokenResponse;
      String? refreshToken = await userIduffRepository.getRefreshToken();

    if (refreshToken == null) return false;

    tokenResponse = await _getNewAccessToken(refreshToken);

    if (tokenResponse == null) return false;

    // Essas linhas configuram o sistema para que todas as futuras chamadas às APIs da UFF sejam automaticamente autenticadas
    client = AuthenticatedClient({
      "Authorization": "Bearer ${tokenResponse.accessToken}",
    });

    AuthResult authResult = await _setInfo(tokenResponse, null);
    return authResult.success;
  }

  Future<AuthResult> _setInfo(
    TokenResponse tokenResponse,
    AuthorizationResponse? authorizationResponse,
  ) async {
    try {
      Map<String, dynamic> userInfo = await getUserInfo(
        tokenResponse.accessToken,
      );

      String iduff = userInfo["preferred_username"];

      // Criar AuthIduffModel
      AuthIduffModel authInfo = AuthIduffModel(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        accessTokenExpiration:
            tokenResponse.accessTokenExpirationDateTime!.millisecondsSinceEpoch,
        codeVerifier: authorizationResponse?.codeVerifier,
        authorizationCode: authorizationResponse?.authorizationCode,
        isLogged: true,
      );

      String photoUrl = _assemblePhotoUrlWithIduff(iduff);

      // Criar e salvar UserIduffModel
      UserIduffModel userAuth = UserIduffModel(
        iduff: iduff,
        fullName: userInfo["name"] ?? '-',
        email: userInfo["email"],
        photoUrl: photoUrl,
        registration: userInfo["registration"] ?? '-',
        vinculacao: userInfo["vinculacao"] ?? '-',
        authData: authInfo,
      );

     await userIduffRepository.saveUserIduffModel(
        userAuth,
      );
     
      return AuthResult(true, "success");
    } catch (e) {
      debugPrint("Erro em Authorize: $e");
      return AuthResult(false, ErrorMessage.erro004);
    }
  }

  // Novo método para montar a URL da foto usando o iduff correto
  String _assemblePhotoUrlWithIduff(String iduff) {
    return "${Secrets.userPhotoBaseUrl}/$iduff";
  }

  // Esta função tenta renovar o token de acesso usando o token de atualização armazenado
  Future<TokenResponse?> _getNewAccessToken(String refreshToken) async {
    TokenResponse? tokenResponse;
    try {
      tokenResponse = await appAuth.token(
        TokenRequest(
          keycloakInfo[keycloakEnv]!.appId,
          Secrets.redirectUri,
          grantType: 'refresh_token',
          refreshToken: refreshToken,
          authorizationCode: await userIduffRepository.getAuthorizationCode(),
          codeVerifier: await userIduffRepository.getCodeVerifier(),
          serviceConfiguration: keycloakInfo[keycloakEnv]!.authServiceConfig,
          scopes: Secrets.authScopes,
        ),
      );
    } on PlatformException catch (e) {
      if (e.message ==
              "Failed to get token: [error: invalid_grant, description: Refresh token expired]" ||
          e.code == "token_failed") {
        return null;
      } else {
        rethrow;
      }
    }
    return tokenResponse;
  }

  Future<Map<String, dynamic>> getUserInfo(token) async {
    client = AuthenticatedClient({"Authorization": "Bearer $token"});
    String baseUrl = Secrets.homologacaoBaseUrl;

    if (keycloakEnv == KeycloakEnvironment.production) {
      baseUrl = Secrets.productionBaseUrl;
    }

    try {
      Uri uri = Uri.https(baseUrl, Secrets.userInfoPath);
      http.Response response = await client!.get(uri);
      
      if (response.statusCode == 200) {
        debugPrint("user info:");
        debugPrint(response.body);
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get UserInfo');
      }
    } catch (e) {
      debugPrint("Erro ao buscar user info: $e");
      throw Exception('Failed to get UserInfo');
    }
  }

  Future<bool> tryLogin() async {
    TokenResponse? tokenResponse;
    try {
      String? refreshToken = await userIduffRepository.getRefreshToken();

      if (refreshToken == null) return false;

      tokenResponse = await _getNewAccessToken(refreshToken);
    } catch (e) {
      return false;
    }

    if (tokenResponse == null) return false;

    AuthResult authResult = await _setInfo(tokenResponse, null);

    return authResult.success;
  }

  Future<String?> getAccessToken() async {
    // Tenta renovar o token, se possível
    await refreshToken();
    // Busca o access token salvo no UserIduffController
    return await userIduffRepository.getAccessToken();
  }
}

class AuthResult {
  final bool success;
  final String message;
  const AuthResult(this.success, this.message);
}
