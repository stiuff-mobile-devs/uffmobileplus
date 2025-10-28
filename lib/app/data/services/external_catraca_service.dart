import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class ExternalCatracaService extends GetxService {
  late UserDataController _userDataController;
  late UserData _userData;
  late final AuthIduffService _auth;

  bool isExpired = false;

  void handleTimeout() {
    isExpired = true;
  }

  Future<void> initialize() async {
    _userDataController = Get.find<UserDataController>();
    _auth = Get.find<AuthIduffService>();
    _userData = (await _userDataController.getUserData())!;
  }

  String getUserIdUFF() {
    return _userData.iduff ?? "-";
  }

  Future<String?> getAccessToken() {
    return _auth.getAccessToken();
  }
}
