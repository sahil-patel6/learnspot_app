import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms_app/Models/Subject.dart';
import 'package:lms_app/Screens/Attendance/AddAttendanceScreen.dart';
import 'package:lms_app/Services/AttendanceService.dart';

import '../../Models/AttendanceSession.dart';
import '../../Models/Student.dart';
import '../../Models/User.dart';
import 'UpdateAttendanceScreen.dart';

class AttendanceScreen extends StatefulWidget {
  Subject? subject;
  final User user;
  Student? student;

  AttendanceScreen({Key? key, this.subject, required this.user, this.student})
      : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isLoading = false;
  String error = "";
  DateTime currentAttendanceSessionDate = DateTime.now();

  List<AttendanceSession> attendance_sessions = [];

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      attendance_sessions.clear();
    });
    try {
      attendance_sessions = await AttendanceService.get_attendances(
        currentAttendanceSessionDate.toUtc().toIso8601String(),
        subject: widget.user.type_of_user == "Teacher" ? widget.subject : null,
        student_id: widget.user.type_of_user == "Student"
            ? widget.user.id
            : widget.student?.id,
      );
      print(attendance_sessions);
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst("Exception: ", "");
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (attendance_sessions.isEmpty) {
        if (error.isEmpty) {
          return const Center(
            child: Text("No attendance has been taken"),
          );
        } else {
          return Center(
            child: Text(error),
          );
        }
      } else {
        return SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendance_sessions.length,
            itemBuilder: (context, index) {
              return buildAttendanceSessionCard(attendance_sessions[index]);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.user.type_of_user != "Student"
          ? AppBar(
              title: const Text("Attendance"),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 18, right: 18),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    currentAttendanceSessionDate = currentAttendanceSessionDate
                        .subtract(const Duration(days: 1));
                    getData();
                  },
                  child: const Icon(
                    Icons.arrow_left,
                    size: 50,
                  ),
                ),
                Text(
                  DateFormat("dd MMM, yyyy")
                      .format(currentAttendanceSessionDate),
                  style: const TextStyle(fontSize: 20),
                ),
                InkWell(
                  onTap: () {
                    currentAttendanceSessionDate = currentAttendanceSessionDate
                        .add(const Duration(days: 1));
                    getData();
                  },
                  child: const Icon(
                    Icons.arrow_right,
                    size: 50,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: buildBody(),
            )
          ],
        ),
      ),
      floatingActionButton: widget.user.type_of_user == "Teacher"
          ? FloatingActionButton(
              onPressed: () async {
                AttendanceSession? attendanceSession = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAttendanceScreen(
                      subject: widget.subject!,
                    ),
                  ),
                );
                if (attendanceSession != null) {
                  setState(() {
                    getData();
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  buildAttendanceSessionCardRow(String title, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  buildAttendanceSessionCard(AttendanceSession attendance_session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.user.type_of_user == "Teacher" ? const Color(0xFFD3D3D3) :
        (attendance_session.attendances
            ?.firstWhere((attendance) =>
        attendance.student?.id == (widget.student != null ? widget.student?.id : widget.user.id))
            .present)!
            ? Colors.green
            : Colors.red,
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.user.type_of_user != "Teacher")
          buildAttendanceSessionCardRow(
            "Subject Name:  ",
            (attendance_session.subject?.name)!,
          ),
          const SizedBox(
            height: 10,
          ),
          buildAttendanceSessionCardRow(
            "Start Time:  ",
            DateFormat("dd MMM, yyyy, HH:mm").format(
              DateTime.parse(
                attendance_session.startTime!,
              ).toLocal(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          buildAttendanceSessionCardRow(
            "End Time:  ",
            DateFormat("dd MMM, yyyy, HH:mm").format(
              DateTime.parse(
                attendance_session.endTime!,
              ).toLocal(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (widget.user.type_of_user == "Student")
            buildAttendanceSessionCardRow(
                "Attendance:  ",
                (attendance_session.attendances
                        ?.firstWhere((attendance) =>
                            attendance.student?.id == widget.user.id)
                        .present)!
                    ? "Present"
                    : "Absent"),
          const SizedBox(
            height: 10,
          ),
          if (widget.user.type_of_user == "Teacher")
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: attendance_session.attendances?.length,
                itemBuilder: (context, index) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildStudentCard(
                          (attendance_session.attendances![index].student)!,
                          attendance_session.attendances![index],
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    )),
          if (widget.user.type_of_user == "Teacher")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    AttendanceSession? updatedAttendanceSession =
                        await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateAttendanceScreen(
                          subject: widget.subject!,
                          attendanceSession: attendance_session,
                        ),
                      ),
                    );
                    if (updatedAttendanceSession != null) {
                      setState(() {
                        attendance_session = updatedAttendanceSession;
                      });
                    }
                  },
                  child: const Text("Update"),
                ),
                DeleteAttendanceSessionButton(
                    attendance_session, removeAttendanceSession),
              ],
            )
        ],
      ),
    );
  }

  removeAttendanceSession(AttendanceSession attendanceSession) {
    setState(() {
      attendance_sessions.remove(attendanceSession);
    });
  }

  renderImage(Student student) {
    if (student.profilePic != "") {
      return CachedNetworkImage(
        imageUrl: student.profilePic!,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(
          value: downloadProgress.progress,
          color: Colors.white,
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.account_circle, size: 50),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.account_circle, size: 50);
    }
  }

  Widget buildStudentCard(Student student, Attendance attendance) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: attendance.present! ? Colors.green : Colors.red,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: Text("Name: ${student.name!}"),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: renderImage(student),
        ),
        subtitle: Text("Roll Number: ${student.rollNumber!}"),
      ),
    );
  }
}

class DeleteAttendanceSessionButton extends StatefulWidget {
  AttendanceSession attendanceSession;
  Function removeAttendanceSession;

  DeleteAttendanceSessionButton(
      this.attendanceSession, this.removeAttendanceSession,
      {Key? key})
      : super(key: key);

  @override
  State<DeleteAttendanceSessionButton> createState() =>
      _DeleteAttendanceSessionButtonState();
}

class _DeleteAttendanceSessionButtonState
    extends State<DeleteAttendanceSessionButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });
        try {
          String response = await AttendanceService.delete_attendance_session(
            widget.attendanceSession.id!,
          );
          print(response);
          widget.removeAttendanceSession(widget.attendanceSession);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response),
            ),
          );
        } catch (e) {
          print(e.toString().replaceFirst("Exception: ", ""));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
          ));
        }
        setState(() {
          isLoading = false;
        });
      },
      child: isLoading
          ? Center(
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          : const Text("Delete"),
    );
  }
}
