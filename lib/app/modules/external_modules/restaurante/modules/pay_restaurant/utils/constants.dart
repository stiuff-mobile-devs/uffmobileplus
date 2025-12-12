import 'package:flutter/material.dart';

class Constants {
  // Strings
  static const CREDIT = "CREDITO";
  static const DEBIT = "DEBITO";
  static const DEFAULT_API_ERROR =
      "Não foi possível obter os dados. Por favor, tente novamente.";
  static const AUTHORIZATION_ERROR_MESSAGE =
      "Ocorreu um erro ao efetuar o login. Por favor, tente novamente.\n\nCódigo do erro: ";
  static const SENTRY_ERROR_FILTER = [
    "PlatformException(authorize_failed, Failed to authorize: [error: null, description: User cancelled flow], null, null)",
    "PlatformException(authorize_failed, Failed to authorize: The operation couldn’t be completed. (org.openid.appauth.general error -3.), null, null)"
  ];
  // IconData
  static const STAR_ON_ICON = Icons.star;
  static const STAR_OFF_ICON = Icons.star_border;
  static const STAR_HALF_ICON = Icons.star_half;
  // Numeric
  static const CARD_QRCODE_EXPIRATION_TIME = 300;

  //Validador da carteirinha
  static const API_URL = String.fromEnvironment('API_ENVIRONMENT') == "PROD"
      ? "app.uff.br"
      : "app.uff.br";
  static const VALIDATE_ENDPOINT =
      "/saci/api/v1/validacoes_carteirinha_digital/validar";
}

enum AuthStatus {
  SUCCESS,
  AUTHORIZATION_ERROR,
  TOKEN_ERROR,
  USERINFO_ERROR,
  USER_BUILD_ERROR,
  OPERATOR_CHECK_ERROR,
  USER_ALLOWED_CHECK_ERROR,
  SECURE_STORAGE_ERROR,
  CANCELLED_LOGIN,
  USER_NOT_ALLOWED,
  UNKNOWN_ERROR
}

extension AuthStatusExtension on AuthStatus {
  static const values = {
    AuthStatus.SUCCESS: '00',
    AuthStatus.AUTHORIZATION_ERROR: '01', // Falha ao fazer a autenticação
    AuthStatus.TOKEN_ERROR: '02', // Falha ao obter o token
    AuthStatus.USERINFO_ERROR:
        '03', // Falha ao obter as informações do endpoint user_info
    AuthStatus.USER_BUILD_ERROR:
        '04', // Falha ao preencher o objeto com os dados de usuário
    AuthStatus.OPERATOR_CHECK_ERROR:
        '05', // Falha no serviço que verifica se o usuário é operador.
    AuthStatus.USER_ALLOWED_CHECK_ERROR:
        '06', // Falha no serviço que checa se o vínculo do usuário é permitido
    AuthStatus.SECURE_STORAGE_ERROR:
        '07', // Erro ao salvar as informações criptografadas do usuário
    AuthStatus.CANCELLED_LOGIN: '97',
    AuthStatus.USER_NOT_ALLOWED: '98', // Usuário não permitido
    AuthStatus.UNKNOWN_ERROR: '99', // Erro inesperado e não mapeado
  };

  String? get value => values[this];
}
