import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class UserDataProvider {
  final String _collectionPath = "user_data";
  final String _userKey = "current_user";

  UserDataProvider() {
    debugPrint("✅ Started User Data provider");
  }

  /// Método privado para gerenciar a abertura do Box e evitar repetição de código
  Future<Box<UserData>> _getBox() async {
    if (Hive.isBoxOpen(_collectionPath)) {
      return Hive.box<UserData>(_collectionPath);
    }
    return await Hive.openBox<UserData>(_collectionPath);
  }

  Future<String> saveUserData(UserData newUserData) async {
    try {
      final box = await _getBox();
      await box.put(_userKey, newUserData);
      return "success";
    } catch (e) {
      throw Exception("Erro ao salvar dados do usuário no Hive: $e");
    }
  }

  Future<UserData?> getUserData() async {
    try {
      final box = await _getBox();
      return box.get(_userKey);
    } catch (e) {
      return null;
    }
  }

  Future<String> clearUserData() async {
    try {
      final box = await _getBox();
      await box.clear();
      return "success";
    } catch (e) {
      return "Erro ao limpar dados do usuário do Hive: $e";
    }
  }

  Future<bool> hasUserData() async {
    try {
      final box = await _getBox();
      return box.containsKey(_userKey);
    } catch (e) {
      debugPrint("Erro ao verificar existência de dados do usuário: $e");
      return false;
    }
  }

  Future<String> updateQrData(String textoQrCodeCarteirinha) async {
    try {
      UserData? user = await getUserData();
      if (user != null) {
        user.textoQrCodeCarteirinha = textoQrCodeCarteirinha;
        await user.save(); // Salva a alteração diretamente no HiveObject
        return textoQrCodeCarteirinha;
      }
      return "Usuario não encontrado";
    } catch (e) {
      return "Erro ao atualizar status de login no Hive: $e";
    }
  }

  Future<String> updateShortcutRoutes(List<String> shortcutRoutes) async {
    try {
      UserData? user = await getUserData();
      if (user != null) {
        user.shortcutRoutes = List<String>.from(shortcutRoutes);
        await user.save();
        return "success";
      }
      return "Usuario não encontrado";
    } catch (e) {
      return "Erro ao atualizar atalhos no Hive: $e";
    }
  }

  Future<String> updateGdiGroupsGoogle(GdiGroupsGoogle gdiGroupsGoogle) async {
    try {
      UserData? user = await getUserData();
      if (user != null) {
        user.gdiGroupsGoogle = gdiGroupsGoogle;
        await user.save();
      } else {
        await saveUserData(UserData(gdiGroupsGoogle: gdiGroupsGoogle));
      }
      return "success";
    } catch (e) {
      return "Erro ao atualizar grupos GDI Google no Hive: $e";
    }
  }

  Future<String> lastRegisteredTokenCdcUpdate(
    DateTime lastRegisteredTokenCdcUpdate,
    String method,
  ) async {
    try {
      UserData? user = await getUserData();
      if (user != null) {
        user.lastRegisteredTokenCdcUpdate = lastRegisteredTokenCdcUpdate;
        user.lastRegisteredTokenCdcMethod = method;
        await user.save();
      } else {
        await saveUserData(
          UserData(
            lastRegisteredTokenCdcUpdate: lastRegisteredTokenCdcUpdate,
            lastRegisteredTokenCdcMethod: method,
          ),
        );
      }
      return "success";
    } catch (e) {
      return "Erro ao atualizar token CDC no Hive: $e";
    }
  }
}