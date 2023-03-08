import 'Department.dart';

class Semester {
  String? id;
  String? name;
  Department? department;

  Semester({this.id, this.name, this.department});

  Semester.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    department = json['department'] != null
        ? Department.fromJson(json['department'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    if (department != null) {
      data['department'] = department!.toJson();
    }
    return data;
  }
}