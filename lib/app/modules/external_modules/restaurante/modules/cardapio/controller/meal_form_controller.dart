import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/restaurants_controller.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import '../data/models/campus_model.dart';
import '../data/models/meal_model.dart';
import '../data/repository/restaurant_repository.dart';
import 'menu_controller.dart' as menu;

class MealFormController extends GetxController {
  final RestaurantsController restaurantsController =
      Get.find<RestaurantsController>();
  late menu.MenuController menuController;

  MealFormController() {
    menuController = Get.find<menu.MenuController>();
  }

  RxList<String> selectedShifts = <String>[].obs;
  RxList<String> selectedCampus = <String>[].obs;
  RxBool canCreate = true.obs;

  RestaurantRepository restaurantRepository = Get.find<RestaurantRepository>();

  RxList<DateTime?> chosenDates = <DateTime?>[DateTime.now()].obs;
  RxString chosenDatesInString =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
          .obs;
  RxList<DateTime?> pickedDates = <DateTime?>[].obs;

  @override
  void onClose() {
    // Limpa as datas selecionadas quando o controlador é fechado
    pickedDates.clear();
    chosenDates.value = <DateTime?>[DateTime.now()];
    chosenDatesInString.value =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    super.onClose();
  }

  Future<void> selectDates(BuildContext context) async {
    final List<DateTime?>? pickDates = await showCalendarDatePicker2Dialog(
      context: context,
      value: pickedDates,
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        controlsTextStyle: const TextStyle(fontSize: 16),
        dayTextStyle: const TextStyle(fontSize: 16),
        weekdayLabelTextStyle: const TextStyle(fontSize: 16),
        calendarType: CalendarDatePicker2Type.multi,
        daySplashColor: Colors.transparent,
      ),
      dialogSize: const Size(300, 300),
    );

    if (pickDates != null) {
      final newDates = pickDates.where((date) => date != null).toList();
      // Adicionar ou remover datas da lista
      pickedDates.assignAll(newDates);
      // Atualiza a lista de datas escolhidas
      chosenDates.value = pickedDates.where((date) => date != null).toList();
      // Atualiza a string com as datas escolhidas
      if (pickedDates.length <= 3 && pickedDates.isNotEmpty) {
        chosenDatesInString.value = pickedDates
            .map((date) =>
                date != null ? "${date.day}/${date.month}/${date.year}" : '')
            .join(', ');
      } else if (pickedDates.isEmpty) {
        chosenDates.value = <DateTime?>[DateTime.now()].obs;
        chosenDatesInString.value =
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
      } else {
        chosenDatesInString.value =
            '${pickedDates.take(3).map((date) => date != null ? "${date.day}/${date.month}/${date.year}" : '').join(', ')}...';
      }
    }
  }

  Future<void> showLoadingModal(
      BuildContext context, Completer<void> completer) async {
    AppPopups.showLoading('enviando'.tr);
    Future.delayed(const Duration(seconds: 10), () {
      // Completer::: IssueFix - Timeout após modal ser fechado.
      if (!completer.isCompleted) {
        completer.complete();
        AppPopups.hideLoading();
        AppPopups.error(
          'msg_confira_cardapio'.tr,
          title: 'tempo_esgotado_titulo'.tr,
        );
      }
    });
  }

  Future<void> sendEditRequisition(BuildContext context, MealModel meal,
      RxList<MealModel> mealsPressed, menu.MenuController mC) async {
    Completer<void> completer = Completer<void>();
    await showLoadingModal(context, completer);

    int insertionCounter = mealsPressed.length;
    canCreate.value = false;

    for (MealModel item in mealsPressed) {
      int createResponse = 0;
      meal.date = DateTime.parse(item.date);
      meal.campus = item.campus;
      await mC.removeMeal(item,
          notifyStatus: false,
          multipleRemovals: (mealsPressed.length > 1) ? true : false);
      createResponse = await restaurantRepository.createMeal(meal);
      if (item == mealsPressed.last) {
        _handleEditResponse(
            context,
            createResponse,
            DateTime.parse(item.date),
            Campus.getShift(DateTime.parse(item.date)),
            Campus.getName(item.campus ?? 'gr'),
            (mealsPressed.length > 1) ? true : false);
      }
      insertionCounter--;
    }
    mC.clear();
    mC.fetchCards();
    if (insertionCounter == 0) {
      canCreate.value = true;
      if (!completer.isCompleted) {
        completer.complete();
      }
      // Fecha o carregamento (não faz nada se o tempo já esgotou e ele fechou).
      AppPopups.hideLoading();
    }
  }

  Future<void> sendRequisition(
      BuildContext context, MealModel meal, menu.MenuController mC) async {
    Completer<void> completer = Completer<void>();
    await showLoadingModal(context, completer);

    int insertionCounter =
        selectedCampus.length * chosenDates.length * selectedShifts.length;
    canCreate.value = false;

    for (String element in selectedCampus) {
      String? campus = Campus.getSigla(element);
      DateTime? lastDateInsertion = DateTime.now();
      String? lastShiftInsertion = "";
      int outerResponse = 0;
      for (DateTime? d in chosenDates.reversed) {
        lastDateInsertion = d;
        int middleResponse = 0;
        if (d != null) {
          DateTime novaData;
          for (String? s in selectedShifts) {
            lastShiftInsertion = s;
            int innerResponse = 0;
            if (s != null) {
              novaData = _getMealDate(d, s, campus);
              meal.date = novaData;
              meal.campus = campus;
              for (int i = 0; i < 5; i++) {
                if (innerResponse == 0 || innerResponse == 401) {
                  innerResponse = await restaurantRepository.createMeal(meal);
                } else {
                  continue;
                }
              }
              middleResponse = innerResponse;
              insertionCounter--;
            }
          }
        }
        outerResponse = middleResponse;
      }
      _handleResponse(context, outerResponse, lastDateInsertion,
          lastShiftInsertion, element);
    }
    mC.clear();
    mC.fetchCards();
    if (insertionCounter == 0) {
      canCreate.value = true;
      if (!completer.isCompleted) {
        completer.complete();
      }
      // Fecha o carregamento (não faz nada se o tempo já esgotou e ele fechou).
      AppPopups.hideLoading();
    }
  }

  DateTime _getMealDate(DateTime date, String shift, String campus) {
    if (shift == 'Almoço') {
      if (campus == "gr") {}
      return DateTime(date.year, date.month, date.day, campus == 'gr' ? 11 : 12,
          campus == 'gr' ? 15 : 0);
    } else {
      return DateTime(date.year, date.month, date.day, 17, 0);
    }
  }

  /// Data · turno · campus da refeição, para o usuário saber qual falhou.
  String _mealContext(DateTime? lastDate, String? lastShift, String campus) {
    final date =
        "${lastDate?.day ?? 0}/${lastDate?.month ?? 0}/${lastDate?.year ?? 0}";
    return 'erro_campus_data_turno'.trParams({
      'campus': campus,
      'date': date,
      'shift': lastShift ?? '',
    });
  }

  /// Título = o que aconteceu; mensagem = motivo/o que fazer + qual refeição.
  void _showMealError(String titleKey, String reasonKey, String mealContext) {
    AppPopups.error('${reasonKey.tr}\n$mealContext', title: titleKey.tr);
  }

  void _handleResponse(BuildContext context, int response, DateTime? lastDate,
      String? lastShift, String campus) {
    final mealContext = _mealContext(lastDate, lastShift, campus);

    if (response == 201 || response == 200) {
      AppPopups.success(
        chosenDates.length * selectedShifts.length > 1
            ? 'refeicoes_adicionadas_sucesso'.tr
            : 'refeicao_adicionada_sucesso'.tr,
        title: campus,
      );
    } else if (response == 500) {
      _showMealError(
          'nao_foi_possivel_criar_refeicao', 'refeicao_ja_reservada', mealContext);
    } else if (response == 403) {
      _showMealError('nao_foi_possivel_criar_refeicao',
          'horario_criacao_expirado', mealContext);
    } else {
      _showMealError(
          'nao_foi_possivel_criar_refeicao', 'msg_tente_mais_tarde', mealContext);
    }
  }

  void _handleEditResponse(BuildContext context, int response,
      DateTime? lastDate, String? lastShift, String campus, bool many) {
    final mealContext = _mealContext(lastDate, lastShift, campus);

    if (response == 201 || response == 200) {
      AppPopups.success(
        many
            ? 'refeicoes_alteradas_sucesso'.tr
            : 'refeicao_alterada_sucesso'.tr,
        title: campus,
      );
    } else if (response == 403) {
      _showMealError('nao_foi_possivel_editar_refeicao',
          'horario_edicao_expirado', mealContext);
    } else {
      // Inclui o 500, que antes mostrava por engano "não pôde ser removida".
      _showMealError('nao_foi_possivel_editar_refeicao', 'msg_tente_mais_tarde',
          mealContext);
    }
  }
}
