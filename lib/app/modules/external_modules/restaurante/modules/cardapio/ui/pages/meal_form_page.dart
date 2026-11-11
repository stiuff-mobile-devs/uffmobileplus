import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import '../../controller/restaurants_controller.dart';
import '../../data/models/meal_model.dart';
import '../widgets/meal_form_widget.dart';

class MealFormPage extends StatefulWidget {
  final MealModel? predefinition;
  const MealFormPage({super.key, this.predefinition});

  @override
  State<MealFormPage> createState() => _MealFormPageState();
}

class _MealFormPageState extends State<MealFormPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      builder: (RestaurantsController restaurantsController) {
        return Scaffold(
          backgroundColor: AppColors.darkBlue(),
          appBar: AppBars.build(
            title: 'formulario_refeicao'.tr,
            actions: [
              IconButton(
                  onPressed: () {
                    Get.toNamed(Routes.WEB_VIEW, arguments: {
                      'url':
                          'https://citsmart.uff.br/citsmart/pages/knowledgeBasePortal/knowledgeBasePortal.load#/knowledge/4060',
                      'title': 'restaurant'.tr
                    });
                  },
                  icon: const Icon(Icons.question_mark)),
            ],
          ),
          body: (widget.predefinition != null)
              ? MealFormWidget(predefinition: widget.predefinition)
              : const MealFormWidget(),
        );
      },
    );
  }
}
