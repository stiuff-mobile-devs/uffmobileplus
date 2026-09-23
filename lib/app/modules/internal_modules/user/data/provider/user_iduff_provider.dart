import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class UserIduffProvider {
  // Agora acessa a mesma caixa do UserData e GoogleModel
  final String _collectionPath = "user_data"; 
  final String _userKey = "current_user"; 

  UserIduffProvider() {
    debugPrint("✅ Started User Iduff provider");
  }

  /// Método privado para gerenciar a abertura da caixa principal do usuário
  Future<Box<UserData>> _getBox() async {
    if (Hive.isBoxOpen(_collectionPath)) {
      return Hive.box<UserData>(_collectionPath);
    }
    return await Hive.openBox<UserData>(_collectionPath);
  }

  Future<void> saveUserIduffModel(UserIduffModel userAuth) async {
    try {
      final box = await _getBox();
      UserData? userData = box.get(_userKey);

      if (userData != null) {
        userData.userIduffModel = userAuth; 
        await userData.save(); 
      } else {
        // Se o usuário não existir, cria a casca principal já com o IduffModel aninhado
        await box.put(_userKey, UserData(userIduffModel: userAuth));
      }
    } catch (e) {
      debugPrint("Erro ao salvar dados do iduff no Hive: $e");
      throw Exception("Erro ao salvar dados do iduff no Hive: $e");
    }
  }

  Future<UserIduffModel?> getUserIduffModel() async {
    try {
      final box = await _getBox();
      UserData? userData = box.get(_userKey);
      
      return userData?.userIduffModel;
    } catch (e) {
      throw Exception("Erro ao buscar dados do iduff do Hive: $e");
    }
  }

  Future<String> deleteUserIduffModel() async {
    try {
      final box = await _getBox();
      UserData? userData = box.get(_userKey);

      if (userData != null) {
        userData.userIduffModel = null;
        await userData.save(); // Salva a alteração para remover apenas este campo
        return "success";
      }
      return "Usuário não encontrado no Hive";
    } catch (e) {
      return "Erro ao deletar dados do iduff do Hive: $e";
    }
  }

  Future<String?> getRefreshToken() async {
    final userIduff = await getUserIduffModel();
    return userIduff?.authData?.refreshToken;
  }

  Future<String?> getAuthorizationCode() async {
    final userIduff = await getUserIduffModel();
    return userIduff?.authData?.authorizationCode;
  }

  Future<String?> getCodeVerifier() async {
    final userIduff = await getUserIduffModel();
    return userIduff?.authData?.codeVerifier;
  }

  Future<String?> getIduff() async {
    final userIduff = await getUserIduffModel();
    return userIduff?.iduff;
  }

  Future<String?> getAccessToken() async {
    final userIduff = await getUserIduffModel();
    return userIduff?.authData?.accessToken;
  }

  Future<String?> getPhotoUrl() async {
    final userIduff = await getUserIduffModel();
    return userIduff?.photoUrl;
  }
}