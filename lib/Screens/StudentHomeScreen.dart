import 'package:flutter/material.dart';

import '../Models/User.dart';

class StudentHomeScreen extends StatefulWidget {
  User user;
  StudentHomeScreen(this.user);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HOME")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Student ID: ${widget.user.id}"),
            Text("Student Name: ${widget.user.name}")
          ],
        ),
      ),
    );
  }
}
