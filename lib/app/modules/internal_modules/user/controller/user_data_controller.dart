import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_iduff_repository.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class UserDataController extends GetxController {
  UserDataController();

  final UserDataRepository _userDataRepository = UserDataRepository();
  final UserIduffRepository userIduffRepository = UserIduffRepository();
  final AuthIduffService _auth = Get.find<AuthIduffService>();

  Future<String> saveUserData(
    UserUmmModel userUmm,
    String targetMatricula,
    ProfileTypes profileType,
  ) async {
    try {
      List<dynamic>? saciData = await _userDataRepository.getSaciData(
        await _auth.getAccessToken(),
        await userIduffRepository.getIduff(),
        _auth,
      );

      int? gradIndex = 0;
      int? posIndex = 0;
      String name = "-";
      String curso = "-";
      String bond = "Sem vínculo";
      String bondId = "-";
      String matricula = targetMatricula;

      String textoQrCode = await saciData[0] ?? '-';
      String? dataValidadeMatricula = await saciData[1];

      String iduff =
          await userIduffRepository.getIduff() ??
          userUmm.activeBond?.objects?.outerObject?[0].usuario!.iduff ??
          "-";

      String fotoUrl = await userIduffRepository.getPhotoUrl() ?? "-";

      int? bondIndex = _findActiveBond(userUmm, targetMatricula);

      if (profileType == ProfileTypes.grad) {
        gradIndex = _findActiveGrad(userUmm, targetMatricula);

        if (gradIndex != null) {
          name =
              userUmm.grad?.matriculas?[gradIndex].identificacao?.nomesocial ??
              userUmm.grad?.matriculas?[gradIndex].identificacao?.nome ??
              "-";

          curso = userUmm.grad?.matriculas?[gradIndex].nomeCurso ?? "-";
        }
      } else if (profileType == ProfileTypes.pos) {
        posIndex = _findActivePos(userUmm, targetMatricula);

        if (posIndex != null) {
          name = userUmm.pos?.alunos?[posIndex].nome ?? "-";
          curso = userUmm.pos?.alunos?[posIndex].cursoNome ?? "-";
        }
      }
      String nomeSocial =
          userUmm.grad?.matriculas?[gradIndex ?? 0].identificacao?.nomesocial ??
          "-";

      if (name == "-") {
        name =
            userUmm.activeBond?.objects?.outerObject?[0].usuario!.nome ?? "-";
      }

      if (bondIndex != null) {
        bond =
            userUmm
                .activeBond
                ?.objects
                ?.outerObject?[1]
                .innerObjects?[bondIndex]
                .vinculacao
                ?.vinculo ??
            "-";

        bondId =
            userUmm
                .activeBond
                ?.objects
                ?.outerObject?[1]
                .innerObjects?[bondIndex]
                .vinculacao
                ?.id ??
            "-";
      }

      List<GdiGroups>? gdiGroups = await getPersonalGdiGroups(iduff);
      String accessToken = await _auth.getAccessToken() ?? "";
      final existingUserData = await _userDataRepository.getUserData();

      final userData = UserData(
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
        profileType: profileType,
        shortcutRoutes: existingUserData?.shortcutRoutes,
      );
      return await _userDataRepository.saveUserData(userData);
    } catch (e) {
      throw Exception("Erro ao salvar dados do usuário: $e");
    }
  }

  Future<List<GdiGroups>> getPersonalGdiGroups(String iduff) async {
    String token = await _auth.getAccessToken() ?? "";
    List<GdiGroups> groups = await _userDataRepository.getGdiGroups(
      iduff,
      token,
    );
    return groups;
  }

   Future<String> updateQrData() async {
    String? token = await _auth.getAccessToken();
    String? iduffUsuario = await userIduffRepository.getIduff();

    var textoQrCode = await _userDataRepository.getSaciData(token, iduffUsuario, _auth) ;
    return await _userDataRepository.updateQrData(textoQrCode[0]);
  }
  //Se ele não achar tem que colocar um -
  int? _findActiveBond(UserUmmModel userUmm, String targetMatricula) {
    final bondsList = userUmm.activeBond?.objects?.outerObject?[1].innerObjects;
    if (bondsList == null || bondsList.isEmpty) return null;

    final idx = bondsList.indexWhere((io) {
      final foundMatricula = io.vinculacao?.matricula ?? "";
      return foundMatricula == targetMatricula;
    });

    if (idx == -1) return null;

    return idx;
  }

  int? _findActiveGrad(UserUmmModel userUmm, String targetMatricula) {
    final gradList = userUmm.grad?.matriculas;
    if (gradList == null || gradList.isEmpty) return null;

    final idx = gradList.indexWhere((matricula) {
      final foundMatricula = matricula.matricula ?? "";
      return foundMatricula == targetMatricula;
    });

    if (idx == -1) return null;

    return idx;
  }

  int? _findActivePos(UserUmmModel userUmm, String targetMatricula) {
    final posList = userUmm.pos?.alunos;
    if (posList == null || posList.isEmpty) return null;

    final idx = posList.indexWhere((aluno) {
      final foundMatricula = aluno.matricula ?? "";
      return foundMatricula == targetMatricula;
    });

    if (idx == -1) return null;

    return idx;
  }
}
