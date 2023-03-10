import 'package:lms_app/Models/FileData.dart';

class Resource {
  String? title;
  String? description;
  String? subject;
  List<FileData>? files;
  String? id;

  Resource({this.title, this.description, this.subject, this.files, this.id});

  Resource.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    subject = json['subject'];
    if (json['files'] != null) {
      files = <FileData>[];
      json['files'].forEach((v) {
        files!.add(FileData.fromJson(v));
      });
    }
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['subject'] = subject;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    // data['_id'] = id;
    return data;
  }
}