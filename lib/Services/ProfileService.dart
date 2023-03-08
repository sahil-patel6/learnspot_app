import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class ProfileService {

  static Future<User> update_profile(User user) async {
    final http.Response response = await http.put(
      Uri.parse(API.USER_UPDATE_PROFILE_URL(user.id!,(user.type_of_user?.toLowerCase())!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token!}'
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      User updatedUser = User.fromJson(jsonDecode(response.body));
      updatedUser.token = user.token;
      updatedUser.type_of_user = user.type_of_user;
      Preferences.addUser(updatedUser);
      return updatedUser;
    } else {
      print(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<User> get_profile() async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_USER_PROFILE_URL(user.id!,(user.type_of_user?.toLowerCase())!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token!}'
      },
    );
    if (response.statusCode == 200) {
      User updatedUser = User.fromJson(jsonDecode(response.body));
      updatedUser.token = user.token;
      updatedUser.type_of_user = user.type_of_user;
      Preferences.addUser(updatedUser);
      return updatedUser;
    } else {
      print(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

}
