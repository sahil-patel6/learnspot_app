class FileData {
  String? nameOfFile;
  String? downloadUrl;
  String? fcsPath;
  String? typeOfFile;
  int? sizeOfFile;
  String? id;

  FileData(
      {this.nameOfFile,
        this.downloadUrl,
        this.fcsPath,
        this.typeOfFile,
        this.sizeOfFile,
        this.id});

  FileData.fromJson(Map<String, dynamic> json) {
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