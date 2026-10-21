import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/provider/user_umm_provider.dart';

class UserUmmRepository {
  final UserUMMProvider _userDataApi = UserUMMProvider();

  Future<UserUmmModel> getUserData(String? idUFF, String token) async {
    return await _userDataApi.getUserData(idUFF, token);
  }

  Future<String> saveUserUmmModel(UserUmmModel userUmm) async {
    return await _userDataApi.saveUserUmmModel(userUmm);
  }

  Future<UserUmmModel?> getUserUmmModel() async {
    return await _userDataApi.getUserUmmModel();
  }

  Future<String> deleteUserUmmModel() async {
    return await _userDataApi.deleteUserUmmModel();
  }

  Future<String> clearAllUserUmm() async {
    return await _userDataApi.clearAllUserUmm();
  }

  Future<bool> hasUserUmm() async {
    return await _userDataApi.hasUserUmm();
  }
}
