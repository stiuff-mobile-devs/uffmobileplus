import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class ExternalModulesServices extends GetxService {
  late UserDataController _userDataController;
  late UserData _userData;

  bool isExpired = false;

  void handleTimeout() {
    isExpired = true;
  }

  ExternalModulesServices() {
    initialize();
  }

  Future<void> initialize() async {
    _userDataController = Get.find<UserDataController>();
    _userData = (await _userDataController.getUserData())!;
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
}
