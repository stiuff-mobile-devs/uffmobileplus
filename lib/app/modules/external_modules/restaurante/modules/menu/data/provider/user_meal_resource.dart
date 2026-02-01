import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import '../models/meal_model.dart';
import '../models/user_meal_model.dart';
import 'restaurant_api.dart';

class UserMealResource {
  UserMealResource();
  final ExternalModulesServices _menuService =
      Get.find<ExternalModulesServices>();
  //final HTTPService httpService = Get.find<HTTPService>();
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };
  late String? accessToken;

  // Future<StatisticsModel?> getStatistic(DateTime? mealDate) async {
  //   final Uri url = _buildUrl(
  //     "${RestaurantAPI.path}/user_meals",
  //     mealDate == null ? null : {"date": mealDate.toString()},
  //   );
  //
  //   try {
  //     final response = await httpService.get(url);
  //     return _processStatisticResponse(response);
  //   } catch (e) {
  //     _logError('getStatistic', e);
  //     if (e.toString() == 'Null check operator used on a null value') {
  //       rethrow;
  //     }
  //   }
  //   return null;
  // }

  Future<dynamic> confirm(MealModel meal) async {
    final Uri url = _buildUrl("${RestaurantAPI.path}/user_meals/");
    accessToken = await _menuService.getAccessToken();
    final UserMealModel userMeal = UserMealModel(
      mealId: meal.id,
      campus: meal.campus,
      date: meal.date,
    );

    try {
      final response = await http.post(
        url,
        body: jsonEncode(userMeal.toJson()),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      // final response = await httpService.post(
      //   url,
      //   body: jsonEncode(userMeal.toJson()),
      //   headers: jsonHeaders,
      // );
      return _processWriteResponse(
        response,
        "Refeição confirmada com sucesso.",
      );
    } catch (e) {
      _logError('confirm', e);
      if (e.toString() == 'Null check operator used on a null value') {
        rethrow;
      }
    }

    return null;
  }

  // Future<dynamic> unconfirm(MealModel meal) async {
  //   final String idUFF = Get.find<UserRepository>().getIduff();
  //   final Uri url = _buildUrl(
  //     "${RestaurantAPI.path}/user_meals/$idUFF/${meal.date}/${meal.campus}",
  //   );
  //
  //   try {
  //     final response = await httpService.delete(url);
  //     return _processWriteResponse(
  //         response, "Refeição desconfirmada com sucesso.");
  //   } catch (e) {
  //     _logError('unconfirm', e);
  //     if (e.toString() == 'Null check operator used on a null value') {
  //       rethrow;
  //     }
  //   }
  //
  //   return null;
  // }

  Future<UserMealModel?> getMealAccepted(MealModel givenMeal) async {
    final Uri url = _buildUrl("${RestaurantAPI.path}/user_meals/self");
    accessToken = await _menuService.getAccessToken();

    try {
      //final response = await httpService.get(url);
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      return _processGetMealAcceptedResponse(response, givenMeal);
    } catch (e) {
      _logError('getMealAccepted', e);
      if (e.toString() == 'Null check operator used on a null value') {
        rethrow;
      }
    }

    return null;
  }

  Future<List<UserMealModel>?> getMealsAccepted() async {
    final Uri url = _buildUrl("${RestaurantAPI.path}/user_meals/self");
    accessToken = await _menuService.getAccessToken();

    try {
      //final response = await httpService.get(url);
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      return _processGetMealsAcceptedResponse(response);
    } catch (e) {
      _logError('getMealsAccepted', e);
      if (e.toString() == 'Null check operator used on a null value') {
        rethrow;
      }
    }

    return null;
  }

  // Função auxiliar para construir URLs
  Uri _buildUrl(String path, [Map<String, String>? queryParameters]) {
    return Uri(
      host: RestaurantAPI.host,
      path: path,
      queryParameters: queryParameters,
      port: RestaurantAPI.port,
      scheme: RestaurantAPI.scheme,
    );
  }

  // Função auxiliar para processar respostas de estatísticas
  // StatisticsModel? _processStatisticResponse(response) {
  //   if (response != null && response.statusCode == 200) {
  //     return StatisticsModel.fromJson(jsonDecode(response.body));
  //   } else {
  //     _logApiError(response);
  //   }
  //   return null;
  // }

  // Função auxiliar para processar respostas de escrita (POST, DELETE)
  dynamic _processWriteResponse(response, String successMessage) {
    if (response != null) {
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint(successMessage);
        return response.body;
      } else {
        _logApiError(response);
        return response.statusCode;
      }
    }
    return null;
  }

  // Função auxiliar para processar resposta de getMealAccepted
  UserMealModel? _processGetMealAcceptedResponse(
    response,
    MealModel givenMeal,
  ) {
    if (response != null && response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      for (var meal in jsonResponse) {
        if (meal['meal_date'] == givenMeal.date &&
            meal['meal_campus'] == givenMeal.campus) {
          return UserMealModel.fromJson(meal);
        }
      }
    } else {
      _logApiError(response);
    }
    return null;
  }

  // Função auxiliar para processar respostas de getMealsAccepted
  List<UserMealModel>? _processGetMealsAcceptedResponse(response) {
    if (response != null) {
      final List<UserMealModel> mealsAccepted = [];
      final jsonResponse = jsonDecode(response.body);
      for (var meal in jsonResponse) {
        mealsAccepted.add(UserMealModel.fromJson(meal));
      }
      return mealsAccepted;
    } else {
      _logApiError(response);
    }
    return null;
  }

  // Função auxiliar para log de erros da API
  void _logApiError(response) {
    debugPrint('RestaurantAPI failed.\nStatus Code: ${response?.statusCode}');
  }

  // Função auxiliar para log de erros gerais
  void _logError(String functionName, dynamic error) {
    debugPrint('Error - $functionName: $error');
  }
}
