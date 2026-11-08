import 'dart:convert';
import 'dart:io';

import 'package:foodly/Utils/network.dart';
import 'package:foodly/model/dishes_model.dart';
import 'package:foodly/model/offer_model.dart';
import 'package:foodly/model/restaurant_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantService {
  static var token = "";
  static _readToken() async {
    final prefs = await SharedPreferences.getInstance();

    var tokenValue = prefs.getString('token') ?? "";

    token = tokenValue;
  }

  _headersAuth(String tokens) async {
    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $tokens",
    };
    return headers;
  }

  Future<List<RestaurantModel>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('$apiUrl/restaurants'));

    print("response.statusCode oo  ${response.statusCode}");
    print("response.statusCode oo  ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("listRest json ${jsonData}");
      var listRest = new List<RestaurantModel>.from(
        jsonData.map((x) => RestaurantModel.fromJSON(x)),
      );
      print("listRest list ${listRest}");
      return listRest;
    } else {
      final errorJson = json.decode(response.body);
      final errorMessage = errorJson['message'];
      throw Exception(errorMessage);
    }
  }

  Future<List<dynamic>> fetchTypesRestaurants() async {
    final response = await http.get(Uri.parse('$apiUrl/restaurants/types'));

    print("response.statusCode oo  ${response.statusCode}");
    print("response.statusCode oo  ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("listRest json ${jsonData}");
      var listTypes = jsonData["data"];
      print("listTypes  ${listTypes}");
      return listTypes;
    } else {
      final errorJson = json.decode(response.body);
      final errorMessage = errorJson['message'];
      throw Exception(errorMessage);
    }
  }

  dynamic registerDishes(var data) async {
    await _readToken();
    print("data restau ${json.encode(data)}");

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/products'),
        headers: await _headersAuth(token),
        body: json.encode(data),
      );
      print('response.body dd : ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("object  ${responseData}");
        return responseData;
      } else {
        final errorMessage = responseData['message'];
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<List<DishesModel>> fetchDishes({required String idRestaurants}) async {
    await _readToken();
    print("data restau ${idRestaurants}");

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/products?restaurantId=$idRestaurants'),
        headers: await _headersAuth(token),
      );
      print('response.body dd : ${response.body}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("object  ${responseData}");
        var listDishes = new List<DishesModel>.from(
          responseData.map((x) => DishesModel.fromJSON(x)),
        );
        print("listDishes list ${listDishes}");
        return listDishes;
      } else {
        final errorMessage = responseData['message'];
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<List<OfferModel>> fetchOffer() async {
    await _readToken();

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/offers'),
        headers: await _headersAuth(token),
      );
      print('response.body dd : ${response.body}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("object  ${responseData}");
        var listOffers = new List<OfferModel>.from(
          responseData["data"].map((x) => OfferModel.fromJSON(x)),
        );
        print(" list offers $listOffers");
        return listOffers;
      } else {
        final errorMessage = responseData['message'];
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  dynamic subscriptionOffer(var data) async {
    await _readToken();
    print("data sub ${json.encode(data)}");

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/subscriptions'),
        headers: await _headersAuth(token),
        body: json.encode(data),
      );
      print('response.body dd : ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("object sub  ${responseData}");
        return responseData;
      } else {
        final errorMessage = responseData['message'];
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<List<SubscriptionModel>> historyMyOffer(String idRestaurant) async {
    await _readToken();

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/subscriptions/my/$idRestaurant'),
        headers: await _headersAuth(token),
      );
      print('response.body dd : ${response.body}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("object subscription ${responseData}");
        var listOffers = new List<SubscriptionModel>.from(
          responseData.map((x) => SubscriptionModel.fromJSON(x)),
        );
        print(" list subscription $listOffers");
        return listOffers;
      } else {
        final errorMessage = responseData['message'];
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
