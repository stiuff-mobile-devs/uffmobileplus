import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_study_plan_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/controller/study_plan_controller.dart';

class StudyPlanBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<ExternalStudyPlanService>(ExternalStudyPlanService(), permanent: true);
    Get.put<StudyPlanController>(StudyPlanController());
    Get.appendTranslations({
      'pt_BR': {
        'plano_estudos': 'Plano de Estudos',
        'turma': 'Turma',
        'codigo': 'Código',
        'horario': 'Horário',
        'as': 'às',
        'status': 'Status',
      },
      'en_US': {
        'turma': 'Class',
        'codigo': 'Code',
        'horario': 'Schedule',
        'as': 'to',
        'status': 'Status',
      },
      'it_IT': {
        
      },
    });
  }
}