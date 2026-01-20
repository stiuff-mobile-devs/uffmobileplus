import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';

class ExternalModulesServices extends GetxService {
  late UserDataController _userDataController;
  UserData _userData = UserData();
  late AuthIduffService _auth;

  bool isExpired = false;

  void handleTimeout() {
    isExpired = true;
  }

  ExternalModulesServices() {
    initialize();
  }

  Future<void> initialize() async {
    _userDataController = Get.find<UserDataController>();
    _auth = Get.find<AuthIduffService>();

    _userData = (await _userDataController.getUserData()) ?? UserData();
  }

  String? getUserName() {
    return _userData.name;
  }

  String getUserMatricula() {
    return _userData.matricula ?? "-";
  }

  String getUserIdUFF() {
    return _userData.iduff ?? "-";
  }

  String getUserCourse() {
    return _userData.curso ?? "-";
  }

  String getUserPhotoUrl() {
    return _userData.fotoUrl ?? "";
  }

  String getUserValidity() {
    return _userData.dataValidadeMatricula ?? "";
  }

  String getUserBond() {
    return _userData.bond ?? "";
  }

  Future<String> getQrCodeData() async {
    return _userData.textoQrCodeCarteirinha ?? "";
  }

  Future<String> updateQrCodeData() async {
    return await _userDataController.updateQrData();
  }

  Future<String?> getAccessToken() {
    return _auth.getAccessToken();
  }

  String getUserBondId() {
    return _userData.bondId ?? "";
  }

  List<GdiGroups>? getUserGdiGroups() {
    return _userData.gdiGroups;
  }

  bool isInGroup(GdiGroupsEnum gdiGroup) {
    final groupsList = getUserGdiGroups();
    if (groupsList == null) return false;
    for (var group in groupsList) {
      if (group.gid! == gdiGroup.id) {
        return true;
      }
    }
    return false;
  }
}
