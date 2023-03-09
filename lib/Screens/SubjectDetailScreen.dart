import 'package:flutter/material.dart';
import 'package:lms_app/Models/Subject.dart';
import 'package:lms_app/Screens/Assignment/AssignmentsScreen.dart';
import 'package:lms_app/Screens/Notice/NoticesScreen.dart';
import 'package:lms_app/Screens/Resource/ResourcesScreen.dart';

import '../Models/User.dart';

class SubjectDetailScreen extends StatefulWidget {
  final User user;
  final Subject subject;

  const SubjectDetailScreen(
      {Key? key, required this.subject, required this.user})
      : super(key: key);

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.subject.name ?? "Subject Detail Screen"),
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
                        builder: (context) => ResourcesScreen(
                          subject: widget.subject,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  child: buildCard("Resources"),
                ),
                const SizedBox(
                  height: 18,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentsScreen(
                          subject: widget.subject,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  child: buildCard("Assignments"),
                ),
                const SizedBox(
                  height: 18,
                ),
                InkWell(
                  child: buildCard("Attendance"),
                ),
                const SizedBox(
                  height: 18,
                ),
                if (widget.user.type_of_user == "Teacher")
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticesScreen(
                            semester_id: (widget.subject.semester?.id)!,
                            user: widget.user,
                          ),
                        ),
                      );
                    },
                    child: buildCard(
                      "Notices (${widget.subject.semester?.department?.name}) (${widget.subject.semester?.name})",
                    ),
                  ),
                const SizedBox(
                  height: 18,
                ),
              ],
            ),
          ),
        ));
  }

  buildCard(String title) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Color(0xFFD3D3D3)),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
        ));
  }
}
