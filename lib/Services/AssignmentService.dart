import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lms_app/Models/Assignment.dart';

import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class AssignmentService {
  static Future<List<Assignment>> get_assignments(String subject_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_ASSIGNMENTS(subject_id, user.id!,(user.type_of_user?.toLowerCase())!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<Assignment> assignments = [];
      try {
        jsonDecode(response.body).forEach((resource) {
          assignments.add(Assignment.fromJson(resource));
        });
      } catch (e) {
        print(e);
      }
      return assignments;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<Assignment> create_assignment(Assignment assignment) async {
    User user = await Preferences.getUser();
    final http.Response response =
        await http.post(Uri.parse(API.CREATE_ASSIGNMENT(user.id!)),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ${user.token}'
            },
            body: jsonEncode(assignment.toJson()));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Assignment createdAssignment = Assignment();
      try {
        createdAssignment = Assignment.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return createdAssignment;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<Assignment> update_assignment(Assignment assignment) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.put(
        Uri.parse(API.UPDATE_ASSIGNMENT(assignment.id!, user.id!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.token}'
        },
        body: jsonEncode(assignment.toJson()));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Assignment updatedAssignment = Assignment();
      try {
        updatedAssignment = Assignment.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return updatedAssignment;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<String> delete_assignment(String assignment_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.delete(
      Uri.parse(API.DELETE_ASSIGNMENT(assignment_id, user.id!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      try {
        return jsonDecode(response.body)["message"];
      } catch (e) {
        print(e);
      }
      return "";
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }
}
