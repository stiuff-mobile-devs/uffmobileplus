import 'package:get/get.dart';
import '../data/models/discipline_model.dart';
import '../data/models/study_plan_model.dart';
import '../data/models/weekday_model.dart';
import '../data/repository/study_plan_repository.dart';

class StudyPlanController extends GetxController {
  final StudyPlanRepository _repository = StudyPlanRepository();

  StudyPlanModel? studyPlan;
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    _fetchStudyPlan(false);
  }

  void _fetchStudyPlan(bool isRefresh) async {
    studyPlan = await _repository.getStudyPlan(isRefresh);
    if (studyPlan != null) {
      final plan = studyPlan?.plan;

      studyPlan?.plan = Map.fromEntries(
        plan!.entries.where((e) => (e.value?.isNotEmpty ?? false)),
      ).map((key, value) => MapEntry(key, value!));
    }

    isLoading = false;
    update();
  }

  StudyPlanModel? getStudyPlan() {
    return studyPlan;
  }

  void refreshStudyPlan() {
    isLoading = true;
    update();
    _fetchStudyPlan(true);
  }
}
