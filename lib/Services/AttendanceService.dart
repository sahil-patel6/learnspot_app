import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/AttendanceSession.dart';
import '../Models/Student.dart';
import '../Models/Subject.dart';
import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class AttendanceService {
  static Future<List<Student>> get_students(String semester_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_STUDENTS_BY_SEMESTER(semester_id, user.id!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<Student> students = [];
      try {
        jsonDecode(response.body).forEach((student) {
          students.add(Student.fromJson(student));
        });
      } catch (e) {
        print(e);
      }
      return students;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<List<AttendanceSession>> get_attendances(
      String currentDate, {Subject? subject, String? student_id}) async {
    User user = await Preferences.getUser();
    String temp = "";
    if (subject != null){
      temp="subject=${subject.id!}";
    }else{
      temp="student=$student_id";
    }
    print(Uri.parse(
      "${API.GET_ATTENDANCE_SESSIONS(user.id!, (user.type_of_user?.toLowerCase())!)}?start_date=$currentDate&end_date=$currentDate&$temp",
    ).toString());
    print("user.name");
    final http.Response response = await http.get(
      Uri.parse(
        "${API.GET_ATTENDANCE_SESSIONS(user.id!, (user.type_of_user?.toLowerCase())!)}?start_date=$currentDate&end_date=$currentDate&$temp",
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<AttendanceSession> attendanceSessions = [];
      try {
        jsonDecode(response.body).forEach((attendanceSession) {
          attendanceSessions.add(AttendanceSession.fromJson(attendanceSession));
        });
      } catch (e) {
        print(e);
      }
      return attendanceSessions;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<AttendanceSession> create_attendance(
      AttendanceSession attendanceSession) async {
    User user = await Preferences.getUser();
    final http.Response response =
        await http.post(Uri.parse(API.CREATE_ATTENDACE_SESSION(user.id!)),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ${user.token}'
            },
            body: jsonEncode(attendanceSession.toJson()));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      AttendanceSession createdAttendanceSession = AttendanceSession();
      try {
        createdAttendanceSession =
            AttendanceSession.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return createdAttendanceSession;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<AttendanceSession> update_attendance_session(
      AttendanceSession attendanceSession) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.put(
        Uri.parse(
            API.UPDATE_ATTENDACE_SESSION(attendanceSession.id!, user.id!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.token}'
        },
        body: jsonEncode(attendanceSession.toJson()));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      AttendanceSession attendanceSession = AttendanceSession();
      try {
        attendanceSession =
            AttendanceSession.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return attendanceSession;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<String> delete_attendance_session(
      String attendance_session_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.delete(
      Uri.parse(API.DELETE_ATTENDACE_SESSION(attendance_session_id, user.id!)),
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
