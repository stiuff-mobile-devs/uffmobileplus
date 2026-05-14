import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_iduff_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/provider/user_iduff_provider.dart';

class UserIduffRepository {
  final UserIduffProvider _userIduffProvider = UserIduffProvider();

  UserIduffRepository() {
    debugPrint("Creating User Auth Repo");
  }

  Future<void> saveUserIduffModel(UserIduffModel userAuth) async {
    return await _userIduffProvider.saveUserIduffModel(userAuth);
  }

  Future<UserIduffModel?> getUserIduffModel() async {
    return await _userIduffProvider.getUserIduffModel();
  }

  Future<String> deleteUserIduffModel() async {
    return await _userIduffProvider.deleteUserIduffModel();
  }

  Future<String> clearAllUserIduff() async {
    return await _userIduffProvider.clearAllUserIduff();
  }

  Future<bool> hasUserAuth() async {
    return await _userIduffProvider.hasUserAuth();
  }

//Logica de authenticação
Future<String> updateIsLogged(bool isLogged) async {
    return await _userIduffProvider.updateIsLogged(isLogged);
  }

  Future<bool?> getIsLogged() async {
    return await _userIduffProvider.getIsLogged();
  }

  Future<String?> getRefreshToken() async {
    return await _userIduffProvider.getRefreshToken();
  }

  Future<String?> getAuthorizationCode() async {
    return await _userIduffProvider.getAuthorizationCode();
  }

  Future<String?> getCodeVerifier() async {
    return await _userIduffProvider.getCodeVerifier();
  }

  Future<String?> getIduff() async {
    return await _userIduffProvider.getIduff();
  }

  Future<String?> getAccessToken() async {
    return await _userIduffProvider.getAccessToken();
  }

  Future<String?> getPhotoUrl() async {
    return await _userIduffProvider.getPhotoUrl();
  }
}
