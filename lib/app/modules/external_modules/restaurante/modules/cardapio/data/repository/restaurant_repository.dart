import 'package:flutter/cupertino.dart';
import '../models/meal_model.dart';
import '../models/user_meal_model.dart';
import '../provider/restaurant_provider.dart';

class RestaurantRepository {
  RestaurantProvider? restaurantProvider;

  RestaurantRepository() {
    restaurantProvider = RestaurantProvider();
    // var auth = Get.find<Auth>();
    // if (auth.client != null) {
    //   restaurantProvider = RestaurantProvider();
    // }
  }

  Future createMeal(MealModel meal) async {
    var response = await _exec(() => restaurantProvider!.createMeal(meal));
    return response;
  }

  Future updateMeal(MealModel meal) async {
    var response = await _exec(() => restaurantProvider!.updateMeal(meal));
    return response;
  }

  Future<List<MealModel>?> getMealsByCampus(String campus) async {
    var response =
        await _exec(() => restaurantProvider!.getMealsByCampus(campus));
    return response;
  }

  // Future confirm(MealModel meal) async {
  //   var response = await _exec(() => restaurantProvider!.confirm(meal));
  //   return response;
  // }
  //
  // Future unconfirm(MealModel meal) async {
  //   var response = await _exec(() => restaurantProvider!.unconfirm(meal));
  //   return response;
  // }

  Future<UserMealModel?> getMealAccepted(MealModel givenMeal) async {
    var response =
        await _exec(() => restaurantProvider!.getMealAccepted(givenMeal));
    return response;
  }

  Future<List<UserMealModel>?> getMealsAccepted() async {
    var response = await _exec(() => restaurantProvider!.getMealsAccepted());
    return response;
  }

  // Future<StatisticsModel?> getStatistics(DateTime? date) async {
  //   var response = await _exec(() => restaurantProvider!.getStatistics(date));
  //   return response;
  // }

  Future<T?> _exec<T>(Future<T?> Function() f) async {
    if (restaurantProvider == null) {
      debugPrint("RestaurantProvider is null");
      return null;
    }
    try {
      return await f();
    } catch (e) {
      debugPrint("Algum problema ocorreu");
      debugPrint(e.toString());
    }
    return null;
  }
}
