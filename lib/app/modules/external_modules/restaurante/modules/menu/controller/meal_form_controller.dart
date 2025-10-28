import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/controller/restaurants_controller.dart';
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: AlertDialog(
            insetPadding: EdgeInsets.all(0),
            contentPadding: EdgeInsets.fromLTRB(15, 15, 5, 15),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Enviando..."),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 10), () {
      // Completer::: IssueFix - Timeout após modal ser fechado.
      if (!completer.isCompleted) {
        completer.complete();
        Get.back();
        Get.snackbar(
          'Erro: Timeout.',
          'A operação atingiu o tempo limite.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
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
      Navigator.pop(context); // Fechar o modal quando a operação termina
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
      Navigator.pop(context); // Fechar o modal quando a operação termina
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

  void _handleResponse(BuildContext context, int response, DateTime? lastDate,
      String? lastShift, String campus) {
    String formattedDate =
        "${lastDate?.day ?? 0}/${lastDate?.month ?? 0}/${lastDate?.year ?? 0}";
    String shiftMessage = lastShift ?? '';

    if (response == 201 || response == 200) {
      if (chosenDates.length * selectedShifts.length > 1) {
        Get.snackbar(
          campus,
          'Refeições adicionadas com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          campus,
          'Refeição adicionada com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
        );
      }
    } else if (response == 500) {
      Get.snackbar(
        'Erro: [$campus] [$formattedDate] [$shiftMessage]',
        'Uma refeição já foi reservada para a data e turno selecionados.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    } else if (response == 403) {
      Get.snackbar(
        'Erro: [$campus] [$formattedDate] [$shiftMessage]',
        'O horário estipulado para a criação da refeição no turno selecionado foi expirado.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erro: [$campus] [$formattedDate] [$shiftMessage]',
        'Não foi possível criar a refeição.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    }
  }

  void _handleEditResponse(BuildContext context, int response,
      DateTime? lastDate, String? lastShift, String campus, bool many) {
    String formattedDate =
        "${lastDate?.day ?? 0}/${lastDate?.month ?? 0}/${lastDate?.year ?? 0}";
    String shiftMessage = lastShift ?? '';

    if (response == 201 || response == 200) {
      if (many) {
        Get.snackbar(
          campus,
          'Refeições alteradas com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          campus,
          'Refeição alterada com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
        );
      }
    } else if (response == 500) {
      Get.snackbar(
        'Erro: [$campus] [$formattedDate] [$shiftMessage]',
        'A refeição não pôde ser removida.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    } else if (response == 403) {
      Get.snackbar(
        'Erro: [$campus] [$formattedDate] [$shiftMessage]',
        'O horário estipulado para a edição da refeição no turno selecionado foi expirado.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erro: [$campus] [$formattedDate] [$shiftMessage]',
        'Não foi possível editar a refeição.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    }
  }
}
