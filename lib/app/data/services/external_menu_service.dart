import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';

class ExternalMenuService extends GetxService {
  late AuthIduffService _authIduffService;

  ExternalMenuService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _authIduffService = Get.find<AuthIduffService>();
  }

  Future<String?> getAccessToken() async {
    return await _authIduffService.getAccessToken();
  }
}
