import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/provider/user_data_provider.dart';

class UserDataRepository {
  final UserDataProvider _userDataProvider = UserDataProvider();

  UserDataRepository() {
    debugPrint("Creating User Data Repo");
  }

  Future<String> saveUserData(UserData userData) async {
    return await _userDataProvider.saveUserData(userData);
  }

  Future<UserData?> getUserData() async {
    return await _userDataProvider.getUserData();
  }

  Future<String> deleteUserData() async {
    return await _userDataProvider.deleteUserData();
  }

  Future<String> clearAllUserData() async {
    return await _userDataProvider.clearAllUserData();
  }

  Future<bool> hasUserData() async {
    return await _userDataProvider.hasUserData();
  }

  Future<String> updateQrData(String textoQrCodeCarteirinha) async {
    return await _userDataProvider.updateQrData(textoQrCodeCarteirinha);
  }

  Future<List<GdiGroups>> getGdiGroups(String iduff, String token) async {
    return await _userDataProvider.getGdiGroups(iduff, token);
  }
  }
