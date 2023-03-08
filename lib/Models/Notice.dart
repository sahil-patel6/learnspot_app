import 'package:lms_app/Models/FileData.dart';

class Notice {
  String? id;
  String? title;
  String? description;
  String? semester;
  String? type;
  String? date;
  List<FileData>? files;

  Notice(
      {this.id,
      this.title,
      this.description,
      this.semester,
      this.type,
      this.date,
      this.files});

  Notice.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    description = json['description'];
    semester = json['semester'];
    type = json['type'];
    date = json['date'];
    if (json['files'] != null) {
      files = <FileData>[];
      json['files'].forEach((v) {
        files!.add(FileData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['_id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['semester'] = semester;
    data['type'] = type;
    // data['date'] = date;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
