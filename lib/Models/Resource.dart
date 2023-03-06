class Resource {
  String? title;
  String? description;
  String? subject;
  List<ResourceFile>? files;
  String? id;

  Resource({this.title, this.description, this.subject, this.files, this.id});

  Resource.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    subject = json['subject'];
    if (json['files'] != null) {
      files = <ResourceFile>[];
      json['files'].forEach((v) {
        files!.add(ResourceFile.fromJson(v));
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

class ResourceFile {
  String? nameOfFile;
  String? downloadUrl;
  String? fcsPath;
  String? typeOfFile;
  int? sizeOfFile;
  String? id;

  ResourceFile(
      {this.nameOfFile,
        this.downloadUrl,
        this.fcsPath,
        this.typeOfFile,
        this.sizeOfFile,
        this.id});

  ResourceFile.fromJson(Map<String, dynamic> json) {
    nameOfFile = json['name_of_file'];
    downloadUrl = json['download_url'];
    fcsPath = json['fcs_path'];
    typeOfFile = json['type_of_file'];
    sizeOfFile = json['size_of_file'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name_of_file'] = nameOfFile;
    data['download_url'] = downloadUrl;
    data['fcs_path'] = fcsPath;
    data['type_of_file'] = typeOfFile;
    data['size_of_file'] = sizeOfFile;
    // data['_id'] = id;
    return data;
  }
}
