import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/data/provider/restaurant_api.dart';

import '../models/meal_model.dart';
import '../models/user_meal_model.dart';

class RestaurantProvider {
  final RestaurantAPI restaurantAPI = RestaurantAPI();

  Future createMeal(MealModel meal) async {
    var response =
        await _exec(() => restaurantAPI.mealResource.createMeal(meal));
    return response;
  }

  Future updateMeal(MealModel meal) async {
    var response =
        await _exec(() => restaurantAPI.mealResource.updateMeal(meal));
    return response;
  }

  Future<List<MealModel>?> getMealsByCampus(String campus) async {
    var response =
        await _exec(() => restaurantAPI.mealResource.getMealsByCampus(campus));
    return response;
  }

  // Future confirm(MealModel meal) async {
  //   var response =
  //       await _exec(() => restaurantAPI.userMealResource.confirm(meal));
  //   return response;
  // }
  //
  // Future unconfirm(MealModel meal) async {
  //   var response =
  //       await _exec(() => restaurantAPI.userMealResource.unconfirm(meal));
  //   return response;
  // }

  Future<UserMealModel?> getMealAccepted(MealModel givenMeal) async {
    var response = await _exec(
        () => restaurantAPI.userMealResource.getMealAccepted(givenMeal));
    return response;
  }

  Future<List<UserMealModel>?> getMealsAccepted() async {
    var response =
        await _exec(() => restaurantAPI.userMealResource.getMealsAccepted());
    return response;
  }
  //
  // Future<StatisticsModel?> getStatistics(DateTime? date) async {
  //   var response =
  //       await _exec(() => restaurantAPI.userMealResource.getStatistic(date));
  //   return response;
  // }

  Future<T?> _exec<T>(Future<T?> Function() f) async {
    try {
      return await f();
    } catch (e, stackTrace) {
      debugPrint("RestaurantProvider could not complete process.");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      // Get.snackbar(
      //   'Erro 401',
      //   'Falha ao carregar. Por favor, reinicie a página.',
      //   snackPosition: SnackPosition.BOTTOM,
      //   colorText: Colors.white,
      // );
      if (e.toString() == 'Null check operator used on a null value') {
        debugPrint("RestaurantProvider retrying!");
        // Bug fix: Reloads on Keycloak issue. Do NOT remove it.
        return await _exec(() => f());
      }
    }
    return null;
  }
}
