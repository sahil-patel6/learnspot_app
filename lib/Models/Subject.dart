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
    data['_id'] = id;
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

class Department {
  String? id;
  String? name;
  String? description;
  int? totalYears;

  Department({this.id, this.name, this.description, this.totalYears});

  Department.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    description = json['description'];
    totalYears = json['total_years'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['total_years'] = totalYears;
    return data;
  }
}
