import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/config/secrets.dart';

import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';

class UserUMMProvider {
  final String _ummCollectionPath = "user_umm_data";
  final String _ummKey = "current_umm";

  Future<UserUmmModel> getUserData(String? idUFF) async {
    Uri url = Uri(
      host: Secrets.productionBaseUrl,
      path: Secrets.getUserDataUrl,
      scheme: Secrets.deepLinkScheme,
      queryParameters: {"iduff": idUFF, "password": Secrets.passwordForApi},
    );

    try {
      final apiResponse = await http.get(url);

      final statusCode = apiResponse.statusCode;
      final body = apiResponse.body;

      if (statusCode != 200) {
        debugPrint("ERROR WITH API. CODE: $statusCode\n BODY: $body");
        throw Exception("Erro ao obter dados do usuário da API");
      }
      final userJson = jsonDecode(body);
      return UserUmmModel.fromJson(userJson);
    } catch (e) {
      debugPrint("ERROR -getUserData $e");
      throw Exception("Erro ao obter dados do usuário da API: $e");
    }
  }

  Future<String> saveUserUmmModel(UserUmmModel userUmm) async {
    try {
      var box = await Hive.openBox<UserUmmModel>(_ummCollectionPath);
      await box.put(_ummKey, userUmm);
      return "success";
    } catch (e) {
      debugPrint("saveUserUmmModel - erro: $e");
      return "Erro ao salvar dados do UserUmmModel no Hive: $e";
    }
  }

  Future<UserUmmModel?> getUserUmmModel() async {
    try {
      var box = await Hive.openBox<UserUmmModel>(_ummCollectionPath);
      return box.get(_ummKey);
    } catch (e) {
      debugPrint("Erro ao obter dados do UserUmmModel do Hive: $e");
      return UserUmmModel();
    }
  }

  Future<String> deleteUserUmmModel() async {
    try {
      var box = await Hive.openBox<UserUmmModel>(_ummCollectionPath);
      await box.delete(_ummKey);
      return "success";
    } catch (e) {
      return "Erro ao deletar dados do UserUmmModel do Hive: $e";
    }
  }

  Future<String> clearAllUserUmm() async {
    try {
      var box = await Hive.openBox<UserUmmModel>(_ummCollectionPath);
      await box.clear();
      return "success";
    } catch (e) {
      return "Erro ao limpar dados do UserUmmModel do Hive: $e";
    }
  }

  Future<bool> hasUserUmm() async {
    try {
      var box = await Hive.openBox<UserUmmModel>(_ummCollectionPath);
      return box.containsKey(_ummKey);
    } catch (e) {
      debugPrint("Erro ao verificar existência de dados do UserUmmModel: $e");
      return false;
    }
  }
}
