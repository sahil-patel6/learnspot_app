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
