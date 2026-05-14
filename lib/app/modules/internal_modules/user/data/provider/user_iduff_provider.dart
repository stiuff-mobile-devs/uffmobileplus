import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_iduff_model.dart';

class UserIduffProvider {
  final String _collectionPath = "user_auth_data";
  final String _authKey = "current_auth"; // Chave fixa

  UserIduffProvider() {
    debugPrint("Started User Iduff provider");
  }

  Future<void> saveUserIduffModel(UserIduffModel userAuth) async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      await box.put(_authKey, userAuth);
    } catch (e) {
      debugPrint("Erro ao salvar dados do usuário no Hive: $e");
      throw Exception("Erro ao salvar dados do usuário no Hive: $e");
    }
  }

  Future<UserIduffModel?> getUserIduffModel() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      return box.get(_authKey);
    } catch (e) {
      throw Exception("Erro ao buscar dados do usuário do Hive: $e");
    }
  }

  Future<String> deleteUserIduffModel() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      await box.delete(_authKey);
      return "success";
    } catch (e) {
      return "Erro ao deletar dados do usuário do Hive: $e";
    }
  }

  Future<String> clearAllUserIduff() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      await box.clear();
      return "success";
    } catch (e) {
      return "Erro ao limpar dados do usuário do Hive: $e";
    }
  }

  Future<bool> hasUserAuth() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      return box.containsKey(_authKey);
    } catch (e) {
      debugPrint("Erro ao verificar existência de dados do usuário: $e");
      return false;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);
      return user?.authData?.refreshToken;
    } catch (e) {
      debugPrint("Erro ao buscar refresh token: $e");
      return null;
    }
  }

  Future<String?> getAuthorizationCode() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);
      return user?.authData?.authorizationCode;
    } catch (e) {
      debugPrint("Erro ao buscar authorization code: $e");
      return null;
    }
  }

  Future<String?> getCodeVerifier() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);
      return user?.authData?.codeVerifier;
    } catch (e) {
      debugPrint("Erro ao buscar code verifier: $e");
      return null;
    }
  }

  Future<String?> getIduff() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);
      return user?.iduff;
    } catch (e) {
      debugPrint("Erro ao buscar iduff: $e");
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);
      return user?.authData?.accessToken;
    } catch (e) {
      debugPrint("Erro ao buscar access token: $e");
      return null;
    }
  }

  Future<String> updateIsLogged(bool isLogged) async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);

      if (user == null || user.authData == null) {
        return "Nenhuma informação de autenticação encontrada";
      }

      // Atualiza o campo isLogged do authData
      user.authData = AuthIduffModel(
        accessToken: user.authData!.accessToken,
        refreshToken: user.authData!.refreshToken,
        accessTokenExpiration: user.authData!.accessTokenExpiration,
        codeVerifier: user.authData!.codeVerifier,
        authorizationCode: user.authData!.authorizationCode,
        isLogged: isLogged,
      );

      await box.put(_authKey, user);
      return "success";
    } catch (e) {
      return "Erro ao atualizar status de login no Hive: $e";
    }
  }

  Future<bool?> getIsLogged() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);
      return user?.authData?.isLogged;
    } catch (e) {
      debugPrint("Erro ao buscar status de login: $e");
      return null;
    }
  }

  Future<String?> getPhotoUrl() async {
    try {
      var box = await Hive.openBox<UserIduffModel>(_collectionPath);
      UserIduffModel? user = box.get(_authKey);
      return user?.photoUrl;
    } catch (e) {
      debugPrint("Erro ao buscar photoUrl: $e");
      return null;
    }
  }
}
