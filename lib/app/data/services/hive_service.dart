import 'package:hive_flutter/hive_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/study_plan_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/weekday_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_iduff_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';

class HiveService {
  /// Initialize Hive + register all generated adapters.
  static Future<void> init() async {
    await Hive.initFlutter();

  // User UMM adapters
  Hive.registerAdapter(AuthIduffModelAdapter());
  Hive.registerAdapter(UserIduffModelAdapter());
  Hive.registerAdapter(UserUmmModelAdapter());
  Hive.registerAdapter(GradAdapter());
  Hive.registerAdapter(MatriculasAdapter());
  Hive.registerAdapter(CurriculosAdapter());
  Hive.registerAdapter(IdentificacaoAdapter());
  Hive.registerAdapter(PosAdapter());
  Hive.registerAdapter(AlunosAdapter());
  Hive.registerAdapter(ActiveBondAdapter());
  Hive.registerAdapter(ObjectsAdapter());
  Hive.registerAdapter(OuterObjectAdapter());
  Hive.registerAdapter(UsuarioAdapter());
  Hive.registerAdapter(InnerObjectAdapter());
  Hive.registerAdapter(VinculacaoAdapter());
  Hive.registerAdapter(UserGoogleModelAdapter());
  Hive.registerAdapter(UserDataAdapter());
  Hive.registerAdapter(WeekDayAdapter());
    Hive.registerAdapter(DisciplineAdapter());
    Hive.registerAdapter(StudyPlanModelAdapter());
  }
}
