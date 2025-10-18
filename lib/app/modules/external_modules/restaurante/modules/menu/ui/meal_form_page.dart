import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/models/restaurant/meal_model.dart';
import 'package:uffmobileplus/app/modules/restaurant/controllers/restaurants_controller.dart';
import 'package:uffmobileplus/app/util/ui_components/custom_app_bar.dart';
import 'package:uffmobileplus/app/routes/app_pages.dart';
import 'widgets/meal_form_widget.dart';

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
          appBar: customAppBar(
            'Fórmulário de Refeição',
            borderRadius: 0,
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
