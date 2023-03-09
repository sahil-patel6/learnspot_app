import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/Models/Subject.dart';

import '../../Models/AttendanceSession.dart';
import '../../Models/Student.dart';
import '../../Services/AttendanceService.dart';

class AddAttendanceScreen extends StatefulWidget {
  final Subject subject;

  const AddAttendanceScreen({Key? key, required this.subject})
      : super(key: key);

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  bool isLoading = false;
  bool isUploadingAttendance = false;
  String error = "";
  List<Student> students = [];
  AttendanceSession attendanceSession = AttendanceSession();

  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final formKey = GlobalKey<FormState>();

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (students.isEmpty) {
        if (error.isEmpty) {
          return const Center(
            child: Text("No students found"),
          );
        } else {
          return Center(
            child: Text(error),
          );
        }
      } else {
        return buildHomeMainBody();
      }
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      students.clear();
    });
    try {
      students =
          await AttendanceService.get_students((widget.subject.semester?.id)!);
      attendanceSession = AttendanceSession(
        subject: widget.subject,
        semester: (widget.subject.semester)!,
        attendances: [],
      );
      for (var student in students) {
        attendanceSession.attendances?.add(
          Attendance(
            student: student,
            present: true,
          ),
        );
      }
      print(students);
    } catch (e) {
      setState(() {
        error = e.toString();
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

  Widget buildHomeMainBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 25.0,
          left: 15,
          right: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (val) {
                      if (val == null) {
                        return "Please select start time";
                      }
                      return null;
                    },
                    controller: startTimeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.timer),
                      labelText: "Enter Start Time:",
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        initialTime: TimeOfDay.now(),
                        context: context,
                      );

                      if (pickedTime != null) {
                        print(pickedTime.format(context));
                        setState(() {
                          startTimeController.text = pickedTime.format(context);
                          startTime = pickedTime;
                        });
                      } else {
                        print("Time is not selected");
                      }
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    validator: (val) {
                      if (val == null) {
                        return "Please select start time";
                      }
                      return null;
                    },
                    controller: endTimeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.timer),
                      labelText: "Enter End Time:",
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        initialTime: TimeOfDay.now(),
                        context: context,
                      );

                      if (pickedTime != null) {
                        print(pickedTime.format(context));
                        setState(() {
                          endTimeController.text = pickedTime.format(context);
                          endTime = pickedTime;
                        });
                      } else {
                        print("Time is not selected");
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return buildStudentCard(
                    students[index], attendanceSession.attendances![index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Attendance"),
        actions: [
          if (isUploadingAttendance || isLoading)
            Center(
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 10),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    setState(() {
                      isUploadingAttendance = true;
                    });
                    DateTime now = DateTime.now();
                    DateTime actualStartTime = DateTime(now.year, now.month,
                        now.day, (startTime?.hour)!, (startTime?.minute)!);
                    DateTime actualEndTime = DateTime(now.year, now.month,
                        now.day, (endTime?.hour)!, (endTime?.minute)!);
                    print(actualStartTime.toString());
                    print(actualEndTime.toString());
                    if (actualEndTime.isBefore(actualStartTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text("End Time should be greater than Start Time"),
                      ));
                      setState(() {
                        isUploadingAttendance = false;
                      });
                      return;
                    }
                    attendanceSession.startTime =
                        actualStartTime.toUtc().toIso8601String();
                    attendanceSession.endTime =
                        actualEndTime.toUtc().toIso8601String();

                    AttendanceSession createdAttendanceSession =
                        await AttendanceService.create_attendance(
                            attendanceSession);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Attendances Created Successfully"),
                      ),
                    );
                    setState(() {
                      isUploadingAttendance = false;
                    });
                    Navigator.pop(context, createdAttendanceSession);
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                    ));
                    setState(() {
                      isLoading = false;
                      isUploadingAttendance = false;
                    });
                  }
                }
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: buildBody(),
    );
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
    return ListTile(
      onTap: () {
        setState(() {
          if (attendance.present != null) {
            attendance.present = !(attendance.present)!;
          } else {
            attendance.present = true;
          }
        });
      },
      title: Text("Name: ${student.name!}"),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: renderImage(student),
      ),
      subtitle: Text("Roll Number: ${student.rollNumber!}"),
      trailing: Checkbox(
        value: attendance.present,
        onChanged: (value) {
          setState(() {
            attendance.present = value;
          });
        },
      ),
    );
  }
}
