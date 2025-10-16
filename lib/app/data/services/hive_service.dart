import 'package:hive_flutter/hive_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/study_plan_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/weekday_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_iduff_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class HiveService {
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      // User UMM adapters
      Hive.registerAdapter(AuthIduffModelAdapter());
      Hive.registerAdapter(UserIduffModelAdapter());
      Hive.registerAdapter(UserGoogleModelAdapter());
      Hive.registerAdapter(UserDataAdapter());
      Hive.registerAdapter(WeekDayAdapter());
      Hive.registerAdapter(DisciplineAdapter());
      Hive.registerAdapter(StudyPlanModelAdapter());
      Hive.registerAdapter(GdiGroupsAdapter());
    } catch (e, st) {
      print('Hive init/register adapters error: $e\n$st');
    }
  }
}
