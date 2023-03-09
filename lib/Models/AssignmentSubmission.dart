import 'package:lms_app/Models/FileData.dart';

class AssignmentSubmission {
  String? id;
  List<FileData>? submission;
  String? comments;
  Student? student;
  String? assignment;
  String? submissionDate;

  AssignmentSubmission(
      {this.id,
        this.submission,
        this.comments,
        this.student,
        this.assignment,
        this.submissionDate});

  AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    if (json['submission'] != null) {
      submission = <FileData>[];
      json['submission'].forEach((v) {
        submission!.add(FileData.fromJson(v));
      });
    }
    comments = json['comments'];
    student =
    json['student'] != null ? Student.fromJson(json['student']) : null;
    assignment = json['assignment'];
    submissionDate = json['submission_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['_id'] = id;
    if (submission != null) {
      data['submission'] = submission!.map((v) => v.toJson()).toList();
    }
    data['comments'] = comments;
    if (student != null) {
      data['student'] = student?.id;
    }
    data['assignment'] = assignment;
    // data['submission_date'] = submissionDate;
    return data;
  }
}
class Student {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? rollNumber;
  String? bio;
  String? address;
  String? profilePic;
  String? fcsProfilePicPath;

  Student(
      {this.id,
        this.name,
        this.email,
        this.phone,
        this.rollNumber,
        this.bio,
        this.address,
        this.profilePic,
        this.fcsProfilePicPath
      });

  Student.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    rollNumber = json['roll_number'];
    bio = json['bio'];
    address = json['address'];
    profilePic = json['profile_pic'];
    fcsProfilePicPath = json['fcs_profile_pic_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['roll_number'] = rollNumber;
    data['bio'] = bio;
    data['address'] = address;
    data['profile_pic'] = profilePic;
    data['fcs_profile_pic_path'] = fcsProfilePicPath;
    return data;
  }
}
