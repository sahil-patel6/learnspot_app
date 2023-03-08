import 'package:lms_app/Models/FileData.dart';

class Assignment {
  String? id;
  String? title;
  String? description;
  int? marks;
  String? subject;
  String? dueDate;
  bool? isSubmissionAllowed;
  List<FileData>? assignmentQuestionFiles;

  Assignment(
      {this.id,
      this.title,
      this.description,
      this.marks,
      this.subject,
      this.dueDate,
      this.isSubmissionAllowed,
      this.assignmentQuestionFiles});

  Assignment.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    description = json['description'];
    marks = json['marks'];
    subject = json['subject'];
    dueDate = json['dueDate'];
    isSubmissionAllowed = json['isSubmissionAllowed'];
    if (json['assignment_question_files'] != null) {
      assignmentQuestionFiles = <FileData>[];
      json['assignment_question_files'].forEach((v) {
        assignmentQuestionFiles!.add(FileData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['_id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['marks'] = marks;
    data['subject'] = subject;
    data['dueDate'] = dueDate;
    data['isSubmissionAllowed'] = isSubmissionAllowed;
    if (assignmentQuestionFiles != null) {
      data['assignment_question_files'] =
          assignmentQuestionFiles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}