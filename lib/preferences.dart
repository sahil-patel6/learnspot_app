import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Models/User.dart';

class Preferences {
  static getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String data = await prefs.getString("user") ?? "";
    print(data);
    if (data != "") {
      return User.fromJson(jsonDecode(data));
    }
    return null;
  }

  static addUser(User user) async {
    print("${user.type_of_user}user.type_of_user");
    final prefs = await SharedPreferences.getInstance();
    Map<String,dynamic> newUser = user.toJson();
    newUser["token"] = user.token;
    newUser["_id"] = user.id;
    newUser["type_of_user"] = user.type_of_user;
    prefs.setString("user", jsonEncode(newUser));
  }

  static removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
  }
}
