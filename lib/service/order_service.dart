import 'dart:convert';
import 'dart:io';

import 'package:foodly/Utils/network.dart';
import 'package:foodly/model/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrdersService {
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

  dynamic creatOrders(var data) async {
    print("data restau ${json.encode(data)}");

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/orders/orders'),
        headers: {'Content-Type': 'application/json'},
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

  Future<List<OrderModel>> fetchOrders({required String idRestaurants}) async {
    await _readToken();
    print("data restau ${idRestaurants}");

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/orders/restaurant/$idRestaurants'),
        headers: await _headersAuth(token),
      );
      print('response.body dd : ${response.body}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("object  ${responseData}");
        var listOrders = new List<OrderModel>.from(
          responseData['data'].map((x) => OrderModel.fromJSON(x)),
        );
        print("listOrders c ${listOrders}");
        return listOrders;
      } else {
        final errorMessage = responseData['message'];
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  dynamic updateOrders(String idOrder, String status) async {
    await _readToken();
    var data = {"status": status};

    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/orders/$idOrder/status'),
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
}
