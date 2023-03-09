import 'package:lms_app/Models/FileData.dart';

import 'Student.dart';

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
