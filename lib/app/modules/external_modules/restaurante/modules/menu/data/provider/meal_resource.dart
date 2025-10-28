import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/data/provider/restaurant_api.dart';
import 'package:xml/xml.dart';
import '../../../../../../../data/services/external_menu_service.dart';
import '../models/meal_model.dart';

class MealResource {
  MealResource();

  final ExternalMenuService _menuService = Get.find<ExternalMenuService>();
  late String? accessToken;
  //final HTTPService httpService = Get.find<HTTPService>();
  // static final Map<String, String> jsonHeaders = {
  //   'Content-Type': 'application/json',
  //   'Authorization': 'Bearer $accessToken',
  // };

  // Fetchs a LegacyMeal (from previous RestaurantAPI)
  Future<List<LegacyMeal>?> getMenu() async {
    accessToken = await _menuService.getAccessToken();
    Uri url = Uri.https('restaurante.uff.br', '/cardapiomobile.xml');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      }
      );
    //final response = await httpService.get(url);
    if (response == null) return [];
    if (response.statusCode != 200) {
      debugPrint(
          "Error on LegacyMeal!\n STATUS CODE: ${response.statusCode} \n BODY: ${response.body}");
      return [];
    } else {
      XmlDocument xmlDocument = XmlDocument.parse(response.body);
      Iterable<XmlElement> xmlMenu = xmlDocument.findAllElements('node');
      return xmlMenu.map((mealInfo) {
        return LegacyMeal.fromXml(mealInfo);
      }).toList();
    }
  }

  bool isToday(DateTime mealDate) {
    DateTime today = DateTime.now();
    if (mealDate.year == today.year) {
      if (mealDate.month == today.month) {
        if (mealDate.day == today.day) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<List<MealModel>?> getMainCampusMenuByDate() async {
    final mealsList = await getMealsByCampus("gr");
    if (mealsList != null) {
      return mealsList.where((meal) {
        DateTime d = DateTime.parse(meal.date.toString());
        return isToday(d);
      }).toList();
    }

    return null;
  }

  Future<List<MealModel>?> getMealsByCampus(String campus) async {
    accessToken = await _menuService.getAccessToken();
    final Uri url =
        _buildUrl("${RestaurantAPI.path}/meals/active/campus=$campus");

    try {
      //final response = await httpService.get(url);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      return _processGetResponse(response);
    } catch (e) {
      _logError('getMealsByCampus', e);
      if (e.toString() == 'Null check operator used on a null value') {
        rethrow;
      }
    }

    return null;
  }

  Future<int> createMeal(MealModel meal) async {
    final Uri url = _buildUrl("${RestaurantAPI.path}/meals");
    accessToken = await _menuService.getAccessToken();

    try {
      // final response = await httpService.post(
      //   url,
      //   body: jsonEncode(meal.toJson()),
      //   headers: jsonHeaders,
      // );
      final response = await http.post(
        url,
        body: jsonEncode(meal.toJson()),
        headers: {
        'Authorization': 'Bearer $accessToken',
        },
      );
      return _processWriteResponse(response, "Refeição criada com sucesso.");
    } catch (e) {
      _logError('createMeal', e);
      if (e.toString() == 'Null check operator used on a null value') {
        rethrow;
      }
    }

    return 0;
  }

  Future<int> updateMeal(MealModel meal) async {
    final Uri url = _buildUrl("${RestaurantAPI.path}/meals/${meal.id}");
    accessToken = await _menuService.getAccessToken();

    try {
      // final response = await httpService.put(
      //   url,
      //   body: jsonEncode(meal.toJson()),
      //   headers: jsonHeaders,
      // );
      final response = await http.put(
        url,
        body: jsonEncode(meal.toJson()),
        headers: {
        'Authorization': 'Bearer $accessToken',
        },
      );
      return _processWriteResponse(
          response, "Refeição atualizada com sucesso.");
    } catch (e) {
      _logError('updateMeal', e);
      if (e.toString() == 'Null check operator used on a null value') {
        rethrow;
      }
    }

    return 0;
  }

  Future<int> deleteMeal(MealModel meal) async {
    final Uri url = _buildUrl("${RestaurantAPI.path}/meals/${meal.id}");
    accessToken = await _menuService.getAccessToken();

    try {
      // final response = await httpService.delete(
      //   url,
      //   headers: jsonHeaders,
      // );
      final response = await http.delete(
        url,
        headers: {
        'Authorization': 'Bearer $accessToken',
        },
      );
      return _processWriteResponse(response, "Refeição deletada com sucesso.");
    } catch (e) {
      _logError('deleteMeal', e);
    }

    return 0;
  }

  // Função auxiliar para construir URLs
  Uri _buildUrl(String path) {
    return Uri(
      host: RestaurantAPI.host,
      path: path,
      port: RestaurantAPI.port,
      scheme: RestaurantAPI.scheme,
    );
  }

  // Função auxiliar para processar respostas de leitura (GET)
  List<MealModel>? _processGetResponse(response) {
    if (response != null && response.statusCode == 200) {
      final List<MealModel> meals = [];
      final jsonResponse = jsonDecode(response.body);
      for (var meal in jsonResponse) {
        meals.add(MealModel.fromJson(meal));
      }
      return meals;
    } else {
      _logApiError(response);
    }
    return null;
  }

  // Função auxiliar para processar respostas de escrita (POST, PUT, DELETE)
  int _processWriteResponse(response, String successMessage) {
    if (response != null) {
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint(successMessage);
      } else {
        _logApiError(response);
      }
      return response.statusCode;
    }
    return 0;
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
