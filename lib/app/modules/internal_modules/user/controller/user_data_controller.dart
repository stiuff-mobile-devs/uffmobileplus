import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_iduff_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';

class UserDataController extends GetxController {
  UserDataController();

  final UserDataRepository _userDataRepository = UserDataRepository();
  final AuthIduffService _auth = Get.find<AuthIduffService>();

  late final UserIduffController _userIduffController;

  @override
  void onInit() {
    _userIduffController = Get.find<UserIduffController>();

    super.onInit();
  }

  Future<String> saveUserData(UserUmmModel userUmm) async {
    try {
      var saciData = await getSaciData();
      String textoQrCode = await saciData[0] ?? '-';
      String dataValidadeMatricula = await saciData[1] ?? '-';
      String iduff = userUmm.grad?.matriculas?[0].identificacao?.iduff 
      ?? await _userIduffController.getIduff()
      ?? "-";
      String name = userUmm.grad?.matriculas?[0].identificacao?.nomesocial ??
            userUmm.grad?.matriculas?[0].identificacao?.nome ??
            "-";
      String nomeSocial = userUmm.grad?.matriculas?[0].identificacao?.nomesocial ?? "-";
      String matricula = userUmm.grad?.matriculas?[0].matricula ?? "-";
      String curso = userUmm.grad?.matriculas?[0].nomeCurso ?? "-";
      String fotoUrl = await _userIduffController.getPhotoUrl() ?? "-";
      String bond = userUmm
          .activeBond
          ?.objects
          ?.outerObject?[1]
          .innerObjects?[0]
          .vinculacao
          ?.vinculo ??
          "-";
      String bondId = userUmm
          .activeBond
          ?.objects
          ?.outerObject?[1]
          .innerObjects?[0]
          .vinculacao
          ?.id ??
          "-";
        var gdiGroups = await getGdiGroups(iduff);
        String accessToken = await _auth.getAccessToken() ?? "";

      final  userData = UserData(
        name: name,
        nomesocial: nomeSocial,
        matricula: matricula,
        iduff: iduff,
        curso: curso,
        fotoUrl: fotoUrl,
        dataValidadeMatricula: dataValidadeMatricula,
        textoQrCodeCarteirinha: textoQrCode,
        bond: bond,
        bondId: bondId,
        gdiGroups: gdiGroups,
        accessToken: accessToken,
      );
      return await _userDataRepository.saveUserData(userData);
    } catch (e) {
      return Future.error("Erro ao salvar dados do usuário: $e");
    }
  }

  Future<String> updateQrData() async {
    return await _userDataRepository.updateQrData((await getSaciData())[0]);
  }

  Future<UserData?> getUserData() async {
    return await _userDataRepository.getUserData();
  }

  Future<String> deleteUserData() async {
    return await _userDataRepository.deleteUserData();
  }

  Future<String> clearAllUserData() async {
    return await _userDataRepository.clearAllUserData();
  }

  Future<bool> hasUserData() async {
    return await _userDataRepository.hasUserData();
  }

  Future<List<dynamic>> getSaciData() async {
    String? token = await _auth.getAccessToken();
    String? iduffUsuario = await _userIduffController.getIduff();

    var uri = Uri.https(
      Secrets.carteirinhaValidationHost,
      Secrets.carteirinhaValidationPath,
      {"iduff_usuario": iduffUsuario, "token": token ?? ""},
    );
    http.Response response = await _auth.client!.post(uri);
    var responseDecoded = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseDecoded["content"] != null) {
        final data = json.decode(response.body);
        final textoQrCode = data['content']['texto_qr_code'].toString();
        final dataValidade =
            data['content']['dados_usuario']['vinculacoes'][0]['data_validade'];
        return [textoQrCode, dataValidade];
      }
    }
    return [];
  }

  Future<List<GdiGroups>> getGdiGroups(String iduff) async {
    String token = await _auth.getAccessToken() ?? "";
    List<GdiGroups> groups = await _userDataRepository.getGdiGroups(
      iduff,
      token,
    );
    return groups;
  }
}
