import 'dart:convert';
import '../Models/Notice.dart';
import 'package:http/http.dart' as http;


import '../Models/Semester.dart';
import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class NoticeService {
  static Future<List<Notice>> get_notices(String semester_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_NOTICES(semester_id,user.id!,(user.type_of_user?.toLowerCase())!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<Notice> notices = [];
      try {
        jsonDecode(response.body).forEach((resource) {
          notices.add(Notice.fromJson(resource));
        });
      } catch (e) {
        print(e);
      }
      return notices;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<Notice> create_notice(Notice notice,Semester semester) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.post(
        Uri.parse(API.CREATE_NOTICE(user.id!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.token}'
        },
        body: jsonEncode(notice.toJson())
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Notice createdNotice = Notice();
      try {
        createdNotice = Notice.fromJson(jsonDecode(response.body));
        print("PRINTING CREATED NOTICE");
        print(jsonEncode(createdNotice.toJson()));
      } catch (e) {
        print(e);
      }
      return createdNotice;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<Notice> update_notice(Notice notice) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.put(
        Uri.parse(API.UPDATE_NOTICE(notice.id!,user.id!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.token}'
        },
        body: jsonEncode(notice.toJson())
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Notice updatedNotice = Notice();
      try {
        updatedNotice = Notice.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return updatedNotice;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<String> delete_notice(String notice_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.delete(
      Uri.parse(API.DELETE_NOTICE(notice_id,user.id!)),
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
