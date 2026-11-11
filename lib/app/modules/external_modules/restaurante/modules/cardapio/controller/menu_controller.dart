import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/restaurants_controller.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import '../data/models/campus_model.dart';
import '../data/models/meal_model.dart';
import '../data/models/user_meal_model.dart';
import '../data/repository/restaurant_repository.dart';
import '../ui/pages/meal_form_page.dart';

class MenuController extends GetxController {
  MenuController();

  RestaurantsController restaurantController =
      Get.find<RestaurantsController>();
  RestaurantRepository restaurantRepository = Get.find<RestaurantRepository>();
  // FirebaseAnalyticsService firebaseAnalyticsService = Get.find();
  // GdiProvider gdiProvider = Get.find<GdiProvider>();
  // UserRepository userRepository = Get.find<UserRepository>();

  RxBool isBlurred = false.obs;

  RxBool canDelete = false.obs;
  RxBool canEdit = false.obs;

  Campus selectedLocation = Campus(
      name: 'Gragoatá',
      address: 'R. Prof. Marcos Waldemar de Freitas Reis',
      colorId: LocationColor.orange,
      iconImgPath: 'assets/modules/restaurant/img/gr.png',
      panelImgPath: 'assets/modules/restaurant/img/gr-banner.png');

  var _meals = [].obs;
  var _acceptedMeals = [].obs;

  void toggleBlur() {
    isBlurred.value = !isBlurred.value;
  }

  Future<void> fetchMeals() async {
    final meals = await restaurantController.fetchWithRetries(
      Get.context!,
      () => restaurantRepository
          .getMealsByCampus(Campus.getSigla(selectedLocation.name)),
    ) as List<MealModel>;
    // Ordena por data aqui, ao receber: ordenar a RxList dentro do build do
    // MenuWidget notificava os Obx e dava "setState() called during build".
    meals.sort((a, b) => DateTime.parse(a.date.toString())
        .compareTo(DateTime.parse(b.date.toString())));
    _meals.value = meals;
    update();
  }

  Future<void> fetchAcceptedMeals() async {
    _acceptedMeals.value = await restaurantController.fetchWithRetries(
      Get.context!,
      () => restaurantRepository.getMealsAccepted(),
      showTimeout: false,
    ) as List<UserMealModel>;
    update();
  }

  Future<void> fetchAcceptedMeal(MealModel meal) async {
    UserMealModel? inMeal = (await restaurantController.fetchWithRetries(
      Get.context!,
      () => restaurantRepository.getMealAccepted(meal),
    ));
    if (inMeal != null) _acceptedMeals.add(inMeal);
    update();
  }

  void fetchCards() {
    fetchMeals().then((_) {
      fetchAcceptedMeals();
    }).catchError((error) {
      debugPrint('Erro ao carregar refeições: $error');
      AppPopups.error(
        'msg_verifique_internet'.tr,
        title: 'nao_foi_possivel_carregar_refeicoes'.tr,
      );
    });
  }

  bool checkAccepted(MealModel meal) {
    return _acceptedMeals
        .any((m) => meal.campus == m.campus && meal.date == m.date);
  }

  RxList getAcceptedMeals() {
    return _acceptedMeals;
  }

  RxList getMeals() {
    return _meals;
  }

  void clear() {
    _meals.value = [];
    _acceptedMeals.value = [];
    mealsPressedOnto.value = [];
  }

  RxList<MealModel> mealsPressedOnto = <MealModel>[].obs;

  void handleEditAction(RxList<MealModel> mealsPressed) {
    // Captura o item antes: a lista pode mudar até a rota ser construída.
    final meal = mealsPressed.first;
    Get.to(
      () => MealFormPage(
        predefinition: meal,
      ),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> handleDeleteAction(RxList<MealModel> mealsPressed) async {
    int resposta = 0;
    if (mealsPressed.length > 1) {
      resposta = await showDeletionDialog(Get.context!, isMultiple: true);
    } else {
      resposta = await showDeletionDialog(Get.context!, isMultiple: false);
    }
    if (resposta == 200) {
      for (MealModel item in mealsPressed) {
        if (getMeals().contains(item)) {
          if (mealsPressed.last != item) {
            await removeMeal(item,
                notifyStatus: false,
                multipleRemovals: (mealsPressed.length > 1) ? true : false);
          } else {
            await removeMeal(item,
                notifyStatus: true,
                multipleRemovals: (mealsPressed.length > 1) ? true : false);
          }
        }
      }
      clear();
      fetchCards();
    }
  }

  Future<int> showDeletionDialog(BuildContext context,
      {isMultiple = false}) async {
    // Mantém o contrato antigo: 200 confirma, -1 cancela.
    final confirmed = await AppPopups.confirm(
      title: (isMultiple)
          ? 'excluir_refeicoes_titulo'.tr
          : 'excluir_refeicao_titulo'.tr,
      message: (isMultiple)
          ? 'confirmar_exclusao_refeicoes_multi'.tr
          : 'confirmar_exclusao_refeicao'.tr,
      icon: Icons.delete_outline_rounded,
      confirmText: 'excluir'.tr,
      cancelText: 'cancelar'.tr,
      destructive: true,
      dismissible: false,
    );
    return confirmed ? 200 : -1;
  }

  Future<void> removeMeal(MealModel meal,
      {notifyStatus = true, multipleRemovals = false}) async {
    try {
      meal.open = 0;
      int resposta = await restaurantRepository.updateMeal(meal);
      if (notifyStatus) {
        if (resposta == 200) {
          AppPopups.success(
            (!multipleRemovals)
                ? 'refeicao_removida_sucesso'.tr
                : 'refeicoes_removidas_sucesso'.tr,
            title: Campus.getName(meal.campus!),
          );
        } else {
          AppPopups.error(
            'msg_tente_mais_tarde'.tr,
            title: (!multipleRemovals)
                ? 'nao_foi_possivel_remover_refeicao'.tr
                : 'nao_foi_possivel_remover_ao_menos_uma'.tr,
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao remover refeição: $e');
      AppPopups.error(
        'msg_verifique_internet'.tr,
        title: (!multipleRemovals)
            ? 'nao_foi_possivel_remover_refeicao'.tr
            : 'nao_foi_possivel_remover_ao_menos_uma'.tr,
      );
    }
  }

  bool areEqual(RxList<MealModel> mealsPressed) {
    if (mealsPressed.isEmpty) return true;
    MealModel firstElement = mealsPressed.first;
    return mealsPressed.every((item) {
      return item.campus == firstElement.campus &&
          item.dessert == firstElement.dessert &&
          item.garnish == firstElement.garnish &&
          item.garnishIngr == firstElement.garnishIngr &&
          item.main == firstElement.main &&
          item.mainIngr == firstElement.mainIngr &&
          item.observ == firstElement.observ &&
          item.salad1 == firstElement.salad1 &&
          item.salad2 == firstElement.salad2 &&
          item.side == firstElement.side &&
          item.open == firstElement.open &&
          item.sideIngr == firstElement.sideIngr;
    });
  }

  void updateCanEdit() {
    if (mealsPressedOnto.isEmpty) {
      canEdit.value = false;
      return;
    }
    if (areEqual(mealsPressedOnto)) {
      canEdit.value = true;
      return;
    }
    canEdit.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    // firebaseAnalyticsService.logScreen("restaurant_menu", "restaurant_menu",
    //     userRepository.getCurrentProfile().name);
  }
}

class MenuListController extends GetxController {
  final RestaurantRepository restaurantProvider =
      Get.find<RestaurantRepository>();
  // final GdiProvider gdiProvider = Get.find<GdiProvider>();
  // final UserRepository userRepository = Get.find<UserRepository>();

  late final ScrollController scrollController = ScrollController();
  bool isScrolling = false;

  MenuController MMController = Get.find<MenuController>();
  RestaurantsController restaurantsController =
      Get.find<RestaurantsController>();

  String getShortField(String txt, {int maxLength = 30}) {
    return txt.length <= maxLength ? txt : '${txt.substring(0, maxLength)}...';
  }

  String getDayOfWeek(int day) {
    List<String> diasDaSemana = [
      'segunda_feira'.tr,
      'terca_feira'.tr,
      'quarta_feira'.tr,
      'quinta_feira'.tr,
      'sexta_feira'.tr,
      'sabado'.tr,
      'domingo'.tr,
    ];
    return diasDaSemana[day - 1];
  }

  bool checkDate(DateTime mealDate, String? campus) {
    DateTime now = DateTime.now();
    if (mealDate.isAfter(now)) {
      return true;
    } else if (mealDate.year == now.year &&
        mealDate.month == now.month &&
        mealDate.day == now.day) {
      if (campus == "gr" && mealDate.hour == 11) {
        return mealDate.hour + 3 > now.hour ||
            (mealDate.hour + 3 == now.hour &&
                mealDate.minute + 15 > now.minute);
      } else {
        return mealDate.hour + 2 > now.hour ||
            (mealDate.hour + 2 == now.hour && mealDate.minute > now.minute);
      }
    }
    return false;
  }

  // Update Opacity & Drag
  var containerOpacityValues = <double>[].obs;
  var containerLeftValues = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    containerOpacityValues.addAll([1.0]);
    containerLeftValues.addAll([0.0]);
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// Posição horizontal do cartão [i] (0.0 se ainda não foi arrastado).
  double leftValueAt(int i) =>
      i >= 0 && i < containerLeftValues.length ? containerLeftValues[i] : 0.0;

  /// Opacidade do cartão [i] (1.0 se ainda não foi arrastado).
  double opacityValueAt(int i) => i >= 0 && i < containerOpacityValues.length
      ? containerOpacityValues[i]
      : 1.0;

  /// Garante espaço nas listas até o índice [i]. Chamado só em gestos (fora
  /// do build), pois alterar as RxList notifica os Obx dos cartões.
  void _ensureLength(int i) {
    if (i < 0) return;
    while (containerLeftValues.length <= i) {
      containerLeftValues.add(0.0);
    }
    while (containerOpacityValues.length <= i) {
      containerOpacityValues.add(1.0);
    }
  }

  void updateOpacity(int index, double dragPercentage) {
    _ensureLength(index);
    if (index >= 0 && index < containerOpacityValues.length) {
      containerOpacityValues[index] = (1.0 - dragPercentage).clamp(0.0, 1.0);
    }
  }

  RxList<MealModel> getPressedOnto() {
    return MMController.mealsPressedOnto;
  }

  void setPressedOnto(RxList<MealModel> newList) {
    MMController.mealsPressedOnto = newList;
  }

  void handlePress(int index, MealModel meal) {
    if (restaurantsController.isAdminModeEnabled() ?? false) {
      var L = getPressedOnto();
      if (L.contains(meal)) {
        L.remove(meal);
      } else {
        L.add(meal);
      }
      if (L.isNotEmpty) {
        MMController.canDelete.value = true;
      } else {
        MMController.canDelete.value = false;
      }
      MMController.updateCanEdit();
      setPressedOnto(L);
    }
  }

  void handleDragUpdate(int index, double deltaDx, double screenWidth) {
    if (restaurantsController.isAdminModeEnabled() ?? false) {
      _ensureLength(index);
      if (index >= 0 && index < containerLeftValues.length) {
        containerLeftValues[index] += deltaDx * 2;
        containerLeftValues[index] =
            containerLeftValues[index].clamp(0.0, double.infinity);

        double dragPercentage = containerLeftValues[index] / screenWidth;
        updateOpacity(index, dragPercentage);
      }
    }
  }

  void resetContainerStates() {
    containerLeftValues
        .assignAll(List.generate(containerLeftValues.length, (index) => 0.0));
    containerOpacityValues.assignAll(
        List.generate(containerOpacityValues.length, (index) => 1.0));
  }

  void resetContainerState(int index) {
    if (index >= 0 && index < containerLeftValues.length) {
      containerLeftValues[index] = 0.0;
      containerOpacityValues[index] = 1.0;
    }
  }

  bool? shouldTap;
  // Future<bool> showTapWarning(bool toConfirm) async {
  //   await customAlertDialog(
  //     Get.context!,
  //     title: toConfirm ? "Confirmar Presença" : "Desconfirmar Presença",
  //     desc: toConfirm
  //         ? "Você tem certeza de que deseja confirmar sua presença nesta refeição?\nA coleta dessa informação ajudará a equipe de nutricionistas a estimar a demanda no Restaurante Universitário."
  //         : "Você tem certeza de que deseja remover sua confirmação de presença nesta refeição?",
  //     onConfirm: () {
  //       shouldTap = true;
  //     },
  //     onCancel: () {
  //       shouldTap = false;
  //     },
  //     btnConfirmColor: Colors.green,
  //     btnConfirmText: "Sim",
  //     btnCancelText: "Não",
  //     dismissOnTouchOutside: true,
  //     dismissOnBackKeyPress: true,
  //   ).show();
  //   return shouldTap ?? false;
  // }

  RxInt indexIsLoading = RxInt(-1);
  Future<void> handleTap(int index, MealModel meal) async {
    // if (userRepository.getIsLogged()) {
    //   if (indexIsLoading.value != index) {
    //     if (await showTapWarning(!MMController.checkAccepted(meal))) {
    //       indexIsLoading.value = index;
    //       if (MMController.checkAccepted(meal)) {
    //         await restaurantProvider.unconfirm(meal);
    //         MMController.fetchAcceptedMeals();
    //       } else {
    //         if (await restaurantProvider.confirm(meal) != 204) {
    //           MMController.fetchAcceptedMeal(meal);
    //         } else {
    //           Get.snackbar(
    //             'Erro',
    //             'Não é possível confirmar a sua presença em duas refeições com data e turno equivalentes.',
    //             snackPosition: SnackPosition.BOTTOM,
    //             colorText: Colors.white,
    //           );
    //         }
    //       }
    //     }
    //     Future.delayed(const Duration(milliseconds: 500), () {
    //       indexIsLoading.value = -1;
    //     });
    //   }
    // }
  }

  Future<void> handleDragEnd(int index, MealModel meal) async {
    if (restaurantsController.isAdminModeEnabled() ?? false) {
      if (opacityValueAt(index) == 0) {
        int resposta = await MMController.showDeletionDialog(Get.context!);
        Future.delayed(const Duration(milliseconds: 1000), () async {
          if (resposta == 200) {
            await MMController.removeMeal(meal);
            MMController.clear();
            MMController.fetchCards();
            await Future.delayed(const Duration(milliseconds: 500), () {
              resetContainerStates();
            });
          } else if (resposta == -1) {
            resetContainerState(index);
          } else {
            AppPopups.error(
              'msg_tente_mais_tarde'.tr,
              title: 'nao_foi_possivel_remover_refeicao'.tr,
            );
          }
        });
      } else {
        resetContainerState(index);
      }
    }
  }
}
