import 'dart:convert';

import '../Models/Subject.dart';
import 'package:http/http.dart' as http;

import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class StudentHomeScreenService {
  static Future<List<Subject>> get_subjects_list_per_student() async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_LIST_OF_SUBJECTS_BY_STUDENT(user.id!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<Subject> subjects = [];
      try {
        jsonDecode(response.body).forEach((subject) {
          subjects.add(Subject.fromJson(subject));
        });
      } catch (e) {
        print(e);
      }
      return subjects;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }
}
