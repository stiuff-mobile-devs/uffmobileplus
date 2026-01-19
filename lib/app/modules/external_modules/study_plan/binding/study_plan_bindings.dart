import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/controller/study_plan_controller.dart';

class StudyPlanBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<StudyPlanController>(StudyPlanController());
  }
}
