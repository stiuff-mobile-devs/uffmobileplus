import 'package:get/get.dart';
import '../data/models/study_plan_model.dart';
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

  _fetchStudyPlan(bool isRefresh) async {
    studyPlan = await _repository.getStudyPlan(isRefresh);
    isLoading = false;
    update();
  }

  getStudyPlan() {
    return studyPlan?.plan;
  }

  refreshStudyPlan() {
    isLoading = true;
    update();
    _fetchStudyPlan(true);
  }
}
