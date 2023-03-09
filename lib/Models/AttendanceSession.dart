import 'package:lms_app/Models/Student.dart';

import 'Semester.dart';
import 'Subject.dart';

class AttendanceSession {
  String? id;
  Subject? subject;
  Semester? semester;
  String? startTime;
  String? endTime;
  List<Attendance>? attendances;
  String? date;

  AttendanceSession(
      {this.id,
      this.subject,
      this.semester,
      this.startTime,
      this.endTime,
      this.attendances,
      this.date});

  AttendanceSession.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    subject =
        json['subject'] != null ? Subject.fromJson(json['subject']) : null;
    semester =
        json['semester'] != null ? Semester.fromJson(json['semester']) : null;
    startTime = json['start_time'];
    endTime = json['end_time'];
    if (json['attendances'] != null) {
      attendances = <Attendance>[];
      json['attendances'].forEach((v) {
        attendances!.add(Attendance.fromJson(v));
      });
    }
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['_id'] = id;
    // if (subject != null) {
    //   data['subject'] = subject!.toJson();
    // }
    data['subject'] = subject?.id;
    // if (semester != null) {
    //   data['semester'] = semester!.toJson();
    // }
    data['semester'] = semester?.id;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    if (attendances != null) {
      data['attendances'] = attendances!.map((v) => v.toJson()).toList();
    }
    // data['date'] = date;
    return data;
  }
}


class Attendance {
  Student? student;
  bool? present;
  String? id;

  Attendance({this.student, this.present, this.id});

  Attendance.fromJson(Map<String, dynamic> json) {
    student = json['student'] != null
        ? Student.fromJson(json['student'])
        : null;
    present = json['present'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // if (student != null) {
    //   data['student'] = student!.toJson();
    // }
    data['student'] = student?.id;
    data['present'] = present;
    // data['_id'] = id;
    return data;
  }
}
