import 'Semester.dart';

class Subject {
  String? id;
  String? name;
  String? picUrl;
  String? fcsPicPath;
  int? credits;
  Semester? semester;

  Subject(
      {this.id,
      this.name,
      this.picUrl,
      this.fcsPicPath,
      this.credits,
      this.semester});

  Subject.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    picUrl = json['pic_url'];
    fcsPicPath = json['fcs_pic_path'];
    credits = json['credits'];
    semester = json['semester'] != null
        ? Semester.fromJson(json['semester'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['_id'] = id;
    data['name'] = name;
    data['pic_url'] = picUrl;
    data['fcs_pic_path'] = fcsPicPath;
    data['credits'] = credits;
    if (semester != null) {
      data['semester'] = semester!.toJson();
    }
    return data;
  }
}