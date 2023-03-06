import 'dart:convert';

import '../Models/Resource.dart';
import 'package:http/http.dart' as http;


import '../Models/User.dart';
import '../preferences.dart';
import '../utils/Api.dart';

class ResourceService {
  static Future<List<Resource>> get_resources(String subject_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.get(
      Uri.parse(API.GET_RESOURCES(subject_id,user.id!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<Resource> resources = [];
      try {
        jsonDecode(response.body).forEach((resource) {
          resources.add(Resource.fromJson(resource));
        });
      } catch (e) {
        print(e);
      }
      return resources;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<Resource> create_resource(Resource resource) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.post(
      Uri.parse(API.CREATE_RESOURCE(user.id!)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${user.token}'
      },
      body: jsonEncode(resource.toJson())
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Resource resource = Resource();
      try {
        resource = Resource.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return resource;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<Resource> update_resource(Resource resource) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.put(
        Uri.parse(API.UPDATE_RESOURCE(resource.id!,user.id!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.token}'
        },
        body: jsonEncode(resource.toJson())
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Resource resource = Resource();
      try {
        resource = Resource.fromJson(jsonDecode(response.body));
      } catch (e) {
        print(e);
      }
      return resource;
    } else {
      print(response.body);
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  static Future<String> delete_resource(String resource_id) async {
    User user = await Preferences.getUser();
    final http.Response response = await http.delete(
        Uri.parse(API.DELETE_RESOURCE(resource_id,user.id!)),
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
