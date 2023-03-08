import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class SignInService {
  static Future<User> sigin_in(
      {required String type_of_user,
      required String email,
      required String password,
      required String fcm_token}) async {
    final http.Response response = await http.post(
      Uri.parse(API.USER_SIGNIN_URL(type_of_user.toLowerCase())),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "email": email,
        "plainPassword": password,
        "fcm_token": fcm_token,
      }),
    );
    if (response.statusCode == 200) {
      print(response.body);
      User user = User.fromJson(jsonDecode(response.body));
      user.type_of_user = type_of_user;
      Preferences.addUser(user);
      return user;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }
}
