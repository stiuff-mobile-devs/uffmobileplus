import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';

/// Atualiza no Crashlytics quem é o usuário atual, a partir do que está salvo
/// no Hive. Chame depois de login, logout ou troca de perfil.
///
/// Só vão o hash do iduff (ou do uid Google, sem iduff) e dados de perfil sem
/// identificação pessoal: tipo de perfil, vínculo e curso. Nome, e-mail e
/// matrícula não são enviados.
Future<void> syncCrashReporterUser() async {
  try {
    final repository = UserDataRepository();
    final userData = await repository.getUserData();
    final iduffModel = await repository.getUserIduffModel();
    final googleModel = await repository.getUserGoogleModel();

    final iduff = _firstNotEmpty(userData?.iduff, iduffModel?.iduff);
    final googleId = _firstNotEmpty(googleModel?.id);

    final String loginMethod;
    if (iduff != null) {
      loginMethod = googleId != null ? 'iduff+google' : 'iduff';
    } else if (googleId != null) {
      loginMethod = 'google';
    } else {
      loginMethod = 'anonimo';
    }

    CrashReporter.setUser(
      seed: iduff ?? googleId,
      loginMethod: loginMethod,
      profileType: userData?.profileType?.name,
      bondId: userData?.bondId,
      bond: userData?.bond,
      course: userData?.curso,
    );
  } catch (e, s) {
    CrashReporter.recordError(e, s, reason: 'identificar usuário no crashlytics');
  }
}

String? _firstNotEmpty(String? a, [String? b]) {
  if (a != null && a.isNotEmpty) return a;
  if (b != null && b.isNotEmpty) return b;
  return null;
}
