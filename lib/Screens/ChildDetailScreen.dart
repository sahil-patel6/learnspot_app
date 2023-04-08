import 'package:flutter/material.dart';
import 'package:lms_app/Screens/Attendance/AttendanceScreen.dart';
import 'package:lms_app/Screens/Notice/NoticesScreen.dart';

import '../Models/Student.dart';
import '../Models/User.dart';

class ChildDetailScreen extends StatefulWidget {
  final User user;
  final Student student;

  const ChildDetailScreen({Key? key, required this.student, required this.user})
      : super(key: key);

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name ?? "Subject Detail Screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceScreen(
                        user: widget.user,
                        student: widget.student,
                      ),
                    ),
                  );
                },
                child: buildCard("Attendance"),
              ),
              const SizedBox(
                height: 18,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoticesScreen(
                        semester_id: (widget.student.semester?.id)!,
                        user: widget.user,
                      ),
                    ),
                  );
                },
                child: buildCard(
                  "Notices (${widget.student.semester?.department?.name}) (${widget.student.semester?.name})",
                ),
              ),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildCard(String title) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFD3D3D3)),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
        ));
  }
}
