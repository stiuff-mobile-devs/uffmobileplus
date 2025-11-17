import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/choose_profile/controller/choose_profile_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ChooseProfilePage extends GetView<ChooseProfileController> {
  const ChooseProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('escolha_perfil'.tr),
        actions: [
          IconButton(
            onPressed: controller.goToCarteirinhaPage,
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'carteirinha_digital'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'atualizar'.tr,
            onPressed: () {
              controller.fetchData();
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),

      body: Obx(
        () => controller.isBusy.value
            ? Center(child: CustomProgressDisplay())
            : Container(
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
                      ],
                    ),
                  ],
                ),
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
                            "${'matrícula'.tr}: ${controller.userUmm.grad!.matriculas![index].matricula}",
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

  AccordionSection employeeSelection() {
    return AccordionSection(
      header: Text(
        "tecnico_administrativo".tr,
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
        itemCount: controller.employeeQtd,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1.5, color: AppColors.darkBlue()),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.saveUserDataBeforeChooseProfile(
                  ProfileTypes.employee,
                  controller.activeBonds()[index].vinculacao!.matricula!,
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
                            "${controller.activeBonds()[index].vinculacao!.vinculo}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${'matricula'.tr}: ${controller.activeBonds()[index].vinculacao!.matricula}",
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

  AccordionSection teacherAccordion() {
    return AccordionSection(
      header: Text(
        'docente'.tr,
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
        itemCount: controller.teacherQtd,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1.5, color: AppColors.darkBlue()),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.saveUserDataBeforeChooseProfile(
                  ProfileTypes.teacher,
                  controller.activeBonds()[index].vinculacao!.matricula!,
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
                            "${controller.activeBonds()[index].vinculacao!.vinculo}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${'matricula'.tr}: ${controller.activeBonds()[index].vinculacao!.matricula}",
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

  AccordionSection outsourcedAccordion() {
    return AccordionSection(
      header: Text(
        'terceirizado'.tr,
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
        itemCount: controller.outsourcedQtd,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1.5, color: AppColors.darkBlue()),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.saveUserDataBeforeChooseProfile(
                  ProfileTypes.outsourced,
                  controller.activeBonds()[index].vinculacao!.matricula!,
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
                            "${controller.activeBonds()[index].vinculacao!.vinculo}",
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
