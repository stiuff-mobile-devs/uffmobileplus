import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/data/provider/user_meal_resource.dart';

import 'meal_resource.dart';

class RestaurantAPI {
  static String host = "app.uff.br";
  static int? port;
  static String path = "/bandejapp";
  static String scheme = "https";

  late MealResource mealResource;
  late UserMealResource userMealResource;

  RestaurantAPI() {
    mealResource = MealResource();
    userMealResource = UserMealResource();
  }
}
