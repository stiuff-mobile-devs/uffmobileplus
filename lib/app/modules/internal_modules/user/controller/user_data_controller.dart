import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class UserDataController extends GetxController {
  UserDataController();

  final UserDataRepository _userDataRepository = UserDataRepository();
  final AuthIduffService _auth = Get.find<AuthIduffService>();

  /// Tempo máximo de espera pelo SACI durante o login.
  static const Duration _saciLoginTimeout = Duration(seconds: 5);

  Future<String> saveUserData(
    UserUmmModel userUmm,
    String targetMatricula,
    ProfileTypes profileType,
  ) async {
    try {
      UserData? existingUserData = await _userDataRepository.getUserData();

      String? iduff =
          await _userDataRepository.getIduff() ??
          userUmm.activeBond?.objects?.outerObject?[0].usuario?.iduff;

      // QR code e validade vêm do SACI. Se ele falhar ou demorar, o login
      // segue sem esses dados (a carteirinha tenta de novo ao abrir).
      List<dynamic> saciData = const [];
      try {
        saciData = await _userDataRepository.getSaciData(
          await _auth.getAccessToken(),
          await _userDataRepository.getIduff(),
          _auth,
          timeout: _saciLoginTimeout,
        );
      } catch (e, s) {
        CrashReporter.recordError(e, s, reason: 'buscar dados do saci no login');
        debugPrint('Erro ao buscar dados do SACI no login: $e');
      }

      final hasSaciData = saciData.length >= 2;
      // Sem SACI, mantém o que já estava salvo para a mesma pessoa.
      final sameUser =
          iduff != null && existingUserData?.iduff == iduff;
      String? textoQrCode = hasSaciData
          ? saciData[0]?.toString()
          : (sameUser ? existingUserData?.textoQrCodeCarteirinha : null);
      String? dataValidadeMatricula = hasSaciData
          ? saciData[1]?.toString()
          : (sameUser ? existingUserData?.dataValidadeMatricula : null);

      int? gradIndex = 0;
      int? posIndex = 0;
      String? name;
      String? curso;
      String? bond;
      String? bondId;
      String? matricula = targetMatricula;

      String? fotoUrl = await _userDataRepository.getPhotoUrl();

      int? bondIndex = _findActiveBond(userUmm, targetMatricula);

      if (profileType == ProfileTypes.grad) {
        gradIndex = _findActiveGrad(userUmm, targetMatricula);

        if (gradIndex != null) {
          name =
              userUmm.grad?.matriculas?[gradIndex].identificacao?.nomesocial ??
              userUmm.grad?.matriculas?[gradIndex].identificacao?.nome;

          curso = userUmm.grad?.matriculas?[gradIndex].nomeCurso;
        }
      } else if (profileType == ProfileTypes.pos) {
        posIndex = _findActivePos(userUmm, targetMatricula);

        if (posIndex != null) {
          name = userUmm.pos?.alunos?[posIndex].nome;
          curso = userUmm.pos?.alunos?[posIndex].cursoNome;
        }
      }
      String? nomeSocial =
          userUmm.grad?.matriculas?[gradIndex ?? 0].identificacao?.nomesocial;

      name ??= userUmm.activeBond?.objects?.outerObject?[0].usuario?.nome;

      if (bondIndex != null) {
        bond =
            userUmm
                .activeBond
                ?.objects
                ?.outerObject?[1]
                .innerObjects?[bondIndex]
                .vinculacao
                ?.vinculo;

        bondId =
            userUmm
                .activeBond
                ?.objects
                ?.outerObject?[1]
                .innerObjects?[bondIndex]
                .vinculacao
                ?.id;
      }

      List<GdiGroups>? gdiGroups = await getPersonalGdiGroups(iduff ?? "-");
      String accessToken = await _auth.getAccessToken() ?? "";

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
        gdiGroupsGoogle: existingUserData?.gdiGroupsGoogle,
        lastRegisteredTokenCdcUpdate: existingUserData?.lastRegisteredTokenCdcUpdate,
        lastRegisteredTokenCdcMethod: existingUserData?.lastRegisteredTokenCdcMethod,
        userGoogleModel: existingUserData?.userGoogleModel,
        userIduffModel: existingUserData?.userIduffModel,
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
    String? iduffUsuario = await _userDataRepository.getIduff();

    var textoQrCode = await _userDataRepository.getSaciData(
      token,
      iduffUsuario,
      _auth,
    );
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
