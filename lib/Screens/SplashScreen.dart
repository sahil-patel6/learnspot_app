import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/User.dart';
import '../preferences.dart';
import 'ParentHomeScreen.dart';
import 'StudentHomeScreen.dart';
import 'TeacherHomeScreen.dart';
import 'SignInScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String token = "";
  checkIfUserExists() async {
    final User? user = await Preferences.getUser();
    if (user == null) {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false);
    } else if (user.type_of_user == "Teacher") {
      print(user);
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherHomeScreen(user),
          ),
          (route) => false);
    } else if (user.type_of_user == "Student") {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => StudentHomeScreen(user)),
          (route) => false);
    } else if (user.type_of_user == "Parent") {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ParentHomeScreen(user)),
          (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfUserExists();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: CircularProgressIndicator(backgroundColor: Colors.black),
      ),
    );
  }
}
