import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/internal_modules/choose_profile/controller/choose_profile_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ChooseProfilePage extends GetView<ChooseProfileController> {
  const ChooseProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.darkBlue(),
        appBar: controller.isBusy.value
            ? null
            : AppBars.build(
                title: 'escolha_perfil'.tr,
                actions: [
                  IconButton(
                    onPressed: controller.goToCarteirinhaPage,
                    icon: const Icon(Icons.qr_code_2_rounded),
                    tooltip: 'carteirinha_digital'.tr,
                  ),
                  Obx(
                    () => controller.hasControlPermission.value
                        ? IconButton(
                            onPressed: controller.goToCatracaOnlinePage,
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            tooltip: 'catraca'.tr,
                          )
                        : const SizedBox.shrink(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'atualizar'.tr,
                    onPressed: controller.fetchData,
                  ),
                ],
              ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.darkBlueToBlackGradient(),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Accordion(
                    children: [
                      if (controller.gradQtd > 0) gradAccordion(),
                      if (controller.posQtd > 0) posAccordion(),
                      if (controller.employeeQtd > 0) employeeSelection(),
                      if (controller.teacherQtd > 0) teacherAccordion(),
                      if (controller.outsourcedQtd > 0) outsourcedAccordion(),
                      if(controller.postDocResearcherStudentQtd > 0) postDocResearcherStudentAccordion(),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.isBusy.value)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CustomProgressDisplay(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  AccordionSection gradAccordion() {
    return AccordionSection(
      header: Text(
        'graduacao'.tr,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      leftIcon: const Icon(Icons.account_box, color: Colors.white),
      content: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.gradQtd,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1.5, color: AppColors.darkBlue()),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                String matricula =
                    controller.userUmm.grad!.matriculas![index].matricula!;
                controller.saveUserDataBeforeChooseProfile(
                  ProfileTypes.grad,
                  matricula,
                );
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${controller.userUmm.grad!.matriculas![index].nomeCurso}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${'status'.tr}: ${controller.userUmm.grad!.matriculas![index].statusMatricula}",
                          ),
                          Text(
                            "${'matricula'.tr}: ${controller.userUmm.grad!.matriculas![index].matricula}",
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_circle_right_outlined, size: 22),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      headerBackgroundColor: AppColors.darkBlue(),
      contentBorderColor: AppColors.darkBlue(),
    );
  }

  AccordionSection posAccordion() {
    return AccordionSection(
      header: Text(
        "pos_graduacao".tr,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      leftIcon: const Icon(Icons.account_box, color: Colors.white),
      content: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.posQtd,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1.5, color: AppColors.darkBlue()),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.saveUserDataBeforeChooseProfile(
                  ProfileTypes.pos,
                  controller.userUmm.pos!.alunos![index].matricula!,
                );
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${controller.userUmm.pos!.alunos![index].cursoNome}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${controller.userUmm.pos!.alunos![index].descricao}",
                          ),
                          Text(
                            "${'status'.tr}: ${controller.userUmm.pos!.alunos![index].situacao}",
                          ),
                          Text(
                            "${'matricula'.tr}: ${controller.userUmm.pos!.alunos![index].matricula}",
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_circle_right_outlined, size: 22),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      headerBackgroundColor: AppColors.darkBlue(),
      contentBorderColor: AppColors.darkBlue(),
    );
  }

  AccordionSection employeeSelection() => _bondAccordion(
        title: 'tecnico_administrativo'.tr,
        profileType: ProfileTypes.employee,
        bonds: controller.bondsOf(UffBondIds.employee),
      );

  AccordionSection teacherAccordion() => _bondAccordion(
        title: 'docente'.tr,
        profileType: ProfileTypes.teacher,
        bonds: controller.bondsOf(UffBondIds.teacher),
      );

  AccordionSection outsourcedAccordion() => _bondAccordion(
        title: 'terceirizado'.tr,
        profileType: ProfileTypes.outsourced,
        bonds: controller.bondsOf(UffBondIds.outsourced),
        showMatricula: false,
      );

  /// Seção de vínculos de servidor (técnico, docente, terceirizado). Cada
  /// item usa a lista só daquele tipo, então o índice é sempre o certo.
  AccordionSection _bondAccordion({
    required String title,
    required ProfileTypes profileType,
    required List<InnerObject> bonds,
    bool showMatricula = true,
  }) {
    return AccordionSection(
      header: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      leftIcon: const Icon(Icons.account_box, color: Colors.white),
      content: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: bonds.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1.5, color: AppColors.darkBlue()),
        itemBuilder: (context, index) {
          final vinculacao = bonds[index].vinculacao;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.saveUserDataBeforeChooseProfile(
                  profileType,
                  vinculacao?.matricula ?? '',
                );
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vinculacao?.vinculo ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (showMatricula)
                            Text(
                              "${'matricula'.tr}: ${vinculacao?.matricula ?? ''}",
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_circle_right_outlined, size: 22),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      headerBackgroundColor: AppColors.darkBlue(),
      contentBorderColor: AppColors.darkBlue(),
    );
  }

   AccordionSection postDocResearcherStudentAccordion() {
    return AccordionSection(
      header: Text(
        'Pesquisador de Pós-Doutorado'.tr,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      leftIcon: const Icon(Icons.account_box, color: Colors.white),
      content: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.postDocResearcherStudentQtd,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1.5, color: AppColors.darkBlue()),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.saveUserDataBeforeChooseProfile(
                  ProfileTypes.post_doc_researcher_student,
                  controller.postDocBonds()[index].vinculacao?.matricula ?? '',
                );
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.postDocBonds()[index].vinculacao?.vinculo ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_circle_right_outlined, size: 22),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      headerBackgroundColor: AppColors.darkBlue(),
      contentBorderColor: AppColors.darkBlue(),
    );
  }
}
