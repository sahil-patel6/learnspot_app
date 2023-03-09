import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';

import '../Models/User.dart';
import '../Services/SignInService.dart';
import '../utils/requestNotfificationsPermission.dart';
import 'ParentHomeScreen.dart';
import 'StudentHomeScreen.dart';
import 'TeacherHomeScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final type_of_user = ["Teacher", "Student", "Parent"];
  String _currentSelectedValue = "Teacher";

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  color: Colors.white10,
                ),
                child: Image.asset(
                  "assets/images/learnspot_logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
              const Text(
                "Welcome to LearnSpot",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 18,
              ),
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      validator: Validatorless.multiple([
                        Validatorless.required('Email is required'),
                        Validatorless.email('Please Enter a valid Email'),
                      ]),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Email:",
                        labelText: "Email:",
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    TextFormField(
                      controller: passwordController,
                      validator: Validatorless.min(
                          7, "Passworld should have between 8"),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password:",
                        hintText: "Password:",
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                              hintText: 'Please select type of user',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                          isEmpty: _currentSelectedValue == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currentSelectedValue,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _currentSelectedValue = newValue ?? "Teacher";
                                });
                              },
                              items: type_of_user.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          String fcm_token =
                              await FirebaseMessaging.instance.getToken() ?? "";
                          try {
                            User user = await SignInService.sigin_in(
                                type_of_user: _currentSelectedValue,
                                email: emailController.text,
                                password: passwordController.text,
                                fcm_token: fcm_token);
                            print(user.name);
                            if (user.type_of_user == "Teacher") {
                              // ignore: use_build_context_synchronously
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TeacherHomeScreen(user)),
                                  (route) => false);
                            } else if (user.type_of_user == "Student") {
                              // ignore: use_build_context_synchronously
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StudentHomeScreen(user)),
                                  (route) => false);
                            } else if (user.type_of_user == "Parent") {
                              // ignore: use_build_context_synchronously
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ParentHomeScreen(user)),
                                  (route) => false);
                            }
                          } catch (e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString()),
                            ));
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: const Text("Sign in"),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
