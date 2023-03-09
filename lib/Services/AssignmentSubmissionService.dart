import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lms_app/Models/AssignmentSubmission.dart';

import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class AssignmentSubmissionService {
  static Future<List<AssignmentSubmission>> get_assignment_submissions(String assignment_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_ASSIGNMENT_SUBMISSIONS_BY_ASSIGNMENT(assignment_id, user.id!,(user.type_of_user?.toLowerCase())!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<AssignmentSubmission> assignment_submissions = [];
      try {
        jsonDecode(response.body).forEach((resource) {
          assignment_submissions.add(AssignmentSubmission.fromJson(resource));
        });
      } catch (e) {
        print(e);
      }
      return assignment_submissions;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<AssignmentSubmission> create_assignment_submission(AssignmentSubmission assignment_submission) async {
    User user = await Preferences.getUser();
    final http.Response response =
    await http.post(Uri.parse(API.CREATE_ASSIGNMENT_SUBMISSION(user.id!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.token}'
        },
        body: jsonEncode(assignment_submission.toJson()));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      AssignmentSubmission createdAssignmentSubmission = AssignmentSubmission();
      try {
        createdAssignmentSubmission = AssignmentSubmission.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return createdAssignmentSubmission;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<AssignmentSubmission> update_assignment_submission(AssignmentSubmission assignment_submission) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.put(
        Uri.parse(API.UPDATE_ASSIGNMENT_SUBMISSION(assignment_submission.id!, user.id!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.token}'
        },
        body: jsonEncode(assignment_submission.toJson()));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      AssignmentSubmission updatedAssignmentSubmission = AssignmentSubmission();
      try {
        updatedAssignmentSubmission = AssignmentSubmission.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return updatedAssignmentSubmission;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<String> delete_assignment_submission(String assignment_submission_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.delete(
      Uri.parse(API.DELETE_ASSIGNMENT_SUBMISSION(assignment_submission_id, user.id!)),
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
