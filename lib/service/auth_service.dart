import 'dart:convert';

import 'package:foodly/Utils/network.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  dynamic signIn(var data) async {
    print("data sign in ${json.encode(data)}");
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      print('response.body dd : ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 409) {
        if (response.statusCode == 200) {
          print("object  ${responseData["data"]["user"]}");
          _saveToken(responseData["data"]["accessToken"].toString());
        }
        return responseData;
      } else {
        final errorMessage = responseData['message'];
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  dynamic registerRestaurant(var data) async {
    print("data restau ${json.encode(data)}");
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/restaurants/register'),
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

  dynamic uploadMedia(dynamic data) async {
    print("request.body  data${data}");

    final String url = '$apiUrl/media/upload?folder=restaurants';

    var request = http.MultipartRequest("POST", Uri.parse(url));
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    if (data.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          data,
          filename: "product",
          contentType: http.MediaType('image', 'png'),
        ),
      );
    }
    request.headers.addAll(headers);

    var resp = await request.send();
    var response = await http.Response.fromStream(resp);
    print("response.statusCode ${response.statusCode}");
    print("response.body ${response.body}");
    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData["data"]["url"].toString();
    } else {
      final errorJson = json.decode(response.body);
      final errorMessage = errorJson['message'];
      throw Exception(errorMessage);
    }
  }
}
