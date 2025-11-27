import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_tab_view/infinite_scroll_tab_view.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/weekday_model.dart';
import '../../../../utils/color_pallete.dart';
import '../../../../utils/ui_components/custom_progress_display.dart';
import '../controller/study_plan_controller.dart';

class StudyPlanPage extends GetView<StudyPlanController> {
  const StudyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudyPlanController>(
      init: StudyPlanController(),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.blueAccent,
        appBar: AppBar(
          centerTitle: true,
          elevation: 8,
          foregroundColor: Colors.white,
          title: Text('plano_estudos'.tr),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
          ),
        ),
        body: controller.isLoading
            ? Center(child: CustomProgressDisplay())
            : (controller.studyPlan?.plan == null
                  ? Center(child: Text('no_study_plan_info'.tr))
                  : _tabViewWidget(controller.getStudyPlan())),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.mediumBlue(),
          child: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => controller.refreshStudyPlan(),
        ),
      ),
    );
  }

  _tabViewWidget(studyPlan) {
    return InfiniteScrollTabView(
      backgroundColor: Colors.white,
      contentLength: studyPlan.length,
      indicatorColor: AppColors.mediumBlue(),
      tabBuilder: (index, isSelected) {
        WeekDay day = studyPlan.keys.elementAt(index);
        return Text(
          weekdayToString(day),
          style: isSelected
              ? TextStyle(color: AppColors.mediumBlue())
              : const TextStyle(),
        );
      },
      pageBuilder: (context, index, _) {
        return SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.darkBlueToBlackGradient(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.separated(
                separatorBuilder: (___, __) => Divider(
                  thickness: 2.0,
                  color: AppColors.alternativeMediumBlue(),
                ),
                itemCount: studyPlan.values.elementAt(index).length,
                shrinkWrap: true,
                itemBuilder: (context, innerIndex) {
                  Discipline subject = studyPlan.values.elementAt(
                    index,
                  )[innerIndex];
                  return Column(
                    children: [
                      Text(
                        subject.title ?? "",
                        style: TextStyle(color: Colors.white),
                      ),
                      Row(
                        children: [
                          Text(
                            "turma".tr,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            ': ${subject.codClass}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "codigo".tr,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            ': ${subject.cod}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'horario'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            ': ${subject.startTime} ${'as'.tr} ${subject.endTime}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'status'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            ': ${subject.status}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
