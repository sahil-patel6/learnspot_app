import 'dart:convert';

import 'package:lms_app/Models/Child.dart';

import 'package:http/http.dart' as http;

import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class ParentHomeScreenService {
  static Future<List<Child>> get_students_by_parent() async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_STUDENTS_BY_PARENT(user.id!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<Child> children = [];
      try {
        jsonDecode(response.body).forEach((student) {
          children.add(Child.fromJson(student));
        });
      } catch (e) {
        print(e);
      }
      return children;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }
}
