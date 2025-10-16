import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class UserDataProvider {
  final String _collectionPath = "user_data";
  final String _userKey = "current_user";

  UserDataProvider() {
    debugPrint("Started User Data provider");
  }

  Future<String> saveUserData(UserData userData) async {
    try {
      var box = await Hive.openBox<UserData>(_collectionPath);
      await box.put(_userKey, userData);
      return "success";
    } catch (e) {
      return "Erro ao salvar dados do usuário no Hive: $e";
    }
  }

  Future<UserData?> getUserData() async {
    try {
      var box = await Hive.openBox<UserData>(_collectionPath);
      return box.get(_userKey);
    } catch (e) {
      throw Exception("Erro ao buscar dados do usuário do Hive: $e");
    }
  }

  Future<String> deleteUserData() async {
    try {
      var box = await Hive.openBox<UserData>(_collectionPath);
      await box.delete(_userKey);
      return "success";
    } catch (e) {
      return "Erro ao deletar dados do usuário do Hive: $e";
    }
  }

  Future<String> clearAllUserData() async {
    try {
      var box = await Hive.openBox<UserData>(_collectionPath);
      await box.clear();
      return "success";
    } catch (e) {
      return "Erro ao limpar dados do usuário do Hive: $e";
    }
  }

  Future<bool> hasUserData() async {
    try {
      var box = await Hive.openBox<UserData>(_collectionPath);
      return box.containsKey(_userKey);
    } catch (e) {
      debugPrint("Erro ao verificar existência de dados do usuário: $e");
      return false;
    }
  }

  Future<String> updateQrData(String textoQrCodeCarteirinha) async {
    try {
      var box = await Hive.openBox<UserData>(_collectionPath);
      UserData? user = box.get(_userKey);

      if (user == null) {
        return "Nenhuma informação de usuário encontrada";
      }

      // altera o campo diretamente e salva
      user.textoQrCodeCarteirinha = textoQrCodeCarteirinha;
      await user.save(); // persiste o objeto atualizado
      return textoQrCodeCarteirinha;
    } catch (e) {
      return "Erro ao atualizar status de login no Hive: $e";
    }
  }

  Future<List<GdiGroups>> getGdiGroups(String iduff, String token) async {
    
    final path = '${Secrets.gdiGroupsPath}/$iduff${Secrets.gdiGroupsQuery}';
    var uri = Uri.https(
      Secrets.gdiGroupsHost,
      path,
    );
    try{
      final response = await http.get(
        uri,
        headers:{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200){
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((group) => GdiGroups.fromJson(group)).toList();
      }
    }
    catch(e){
      debugPrint("Erro ao buscar grupos GDI: $e");
      return [];
    }
    return []; 
  }
}
