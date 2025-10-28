import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import '../../modules/internal_modules/user/controller/user_data_controller.dart';
import '../../modules/internal_modules/user/data/models/user_data.dart';
import '../../utils/gdi_groups.dart';

class ExternalMenuService extends GetxService {
  late UserDataController _userDataController;
  late AuthIduffService _authIduffService;
  late UserData? _userData;

  ExternalMenuService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _userDataController = Get.find<UserDataController>();
    _authIduffService = Get.find<AuthIduffService>();
    _userData = await _userDataController.getUserData();
  }

  Future<String?> getAccessToken() async {
    return await _authIduffService.getAccessToken();
  }

  List<GdiGroups>? getUserGdiGroups() {
    return _userData!.gdiGroups;
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
