import 'Semester.dart';

class Child {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? rollNumber;
  String? bio;
  String? address;
  String? profilePic;
  String? fcsProfilePicPath;
  Semester? semester;

  Child(
      {this.sId,
        this.name,
        this.email,
        this.phone,
        this.rollNumber,
        this.bio,
        this.address,
        this.profilePic,
        this.fcsProfilePicPath,
        this.semester});

  Child.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    rollNumber = json['roll_number'];
    bio = json['bio'];
    address = json['address'];
    profilePic = json['profile_pic'];
    fcsProfilePicPath = json['fcs_profile_pic_path'];
    semester = json['semester'] != null
        ? Semester.fromJson(json['semester'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['roll_number'] = rollNumber;
    data['bio'] = bio;
    data['address'] = address;
    data['profile_pic'] = profilePic;
    data['fcs_profile_pic_path'] = fcsProfilePicPath;
    if (semester != null) {
      data['semester'] = semester!.toJson();
    }
    return data;
  }
}
