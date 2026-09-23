import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/data/connections/cdc_service.dart';
import 'package:uffmobileplus/app/data/connections/google_service.dart';
import 'package:uffmobileplus/app/data/connections/saci_service.dart';
import 'package:uffmobileplus/app/data/connections/umm_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/provider/user_data_provider.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/provider/user_google_provider.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/provider/user_iduff_provider.dart';

class UserDataRepository {
  final UserDataProvider _userDataProvider = UserDataProvider();
  final SaciService _saciService = SaciService();
  final UmmService _ummService = UmmService();
  final UserGoogleProvider _provider = UserGoogleProvider();
  final GoogleService _googleService = GoogleService();
  final CdcService _cdcService = CdcService();
  final UserIduffProvider _userIduffProvider = UserIduffProvider();

  UserDataRepository() {
    debugPrint("Creating User Data Repo");
  }

  Future<String> saveUserData(UserData userData) async {
    return await _userDataProvider.saveUserData(userData);
  }

  Future<UserData?> getUserData() async {
    return await _userDataProvider.getUserData();
  }

  Future<String> clearUserData() async {
    return await _userDataProvider.clearUserData();
  }

  Future<bool> hasUserData() async {
    return await _userDataProvider.hasUserData();
  }

  Future<String> updateQrData(String textoQrCodeCarteirinha) async {
    return await _userDataProvider.updateQrData(textoQrCodeCarteirinha);
  }

  Future<String> updateShortcutRoutes(List<String> shortcutRoutes) async {
    return await _userDataProvider.updateShortcutRoutes(shortcutRoutes);
  }

  Future<String> updateGdiGroupsGoogle(GdiGroupsGoogle gdiGroupsGoogle) async {
    return await _userDataProvider.updateGdiGroupsGoogle(gdiGroupsGoogle);
  }

  Future<String> lastRegisteredTokenCdcUpdate(
    DateTime lastRegisteredTokenCdcUpdate,
    String method,
  ) async {
    return await _userDataProvider.lastRegisteredTokenCdcUpdate(
      lastRegisteredTokenCdcUpdate,
      method,
    );
  }

  Future<List<GdiGroups>> getGdiGroups(String iduff, String token) async {
    return await _ummService.getGdiGroups(iduff, token);
  }

  Future<List<dynamic>> getSaciData(
    String? token,
    String? iduffUsuario,
    AuthIduffService auth,
  ) async {
    return await _saciService.getSaciData(token, iduffUsuario, auth);
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

  Future<bool> registerTokenCdc(
    String iduffAccessToken,
    String deviceToken,
    String device,
  ) async {
    return await _cdcService.registerToken(
      iduffAccessToken,
      deviceToken,
      device,
    );
  }

  Future<UserGoogleModel> createUserDoc(
    String email,
    String name,
    String uid,
    String urlImage,
  ) async {
    UserGoogleModel user = await _provider.createUserDoc(
      email,
      name,
      uid,
      urlImage,
    );

    return user;
  }

  Future<String> saveUserGoogleModel(UserGoogleModel user) {
    return _provider.saveUserGoogleModel(user);
  }

  Future<UserGoogleModel?> getUserGoogleModel() {
    return _provider.getUserGoogleModel();
  }

  Future<String> deleteUserGoogleModel() {
    return _provider.deleteUserGoogleModel();
  }


  Future<GdiGroupsGoogle> getGdiGroupsGoogle(String token, String email) async {
    return await _googleService.getGdiGroupsGoogle(token, email);
  }
}
