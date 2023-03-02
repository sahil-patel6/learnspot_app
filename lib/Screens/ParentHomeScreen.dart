import 'package:flutter/material.dart';

import '../Models/User.dart';

class ParentHomeScreen extends StatefulWidget {
  User user;
  ParentHomeScreen(this.user);

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Parent ID: ${widget.user.id}"),
            Text("Parent Name: ${widget.user.name}")
          ],
        ),
      ),
    );
  }
}
