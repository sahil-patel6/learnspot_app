import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/Screens/Attendance/AttendanceScreen.dart';
import 'package:lms_app/Screens/Notice/NoticesScreen.dart';
import 'package:lms_app/Services/StudentHomeScreenService.dart';
import 'package:lms_app/utils/requestNotfificationsPermission.dart';

import '../Models/Subject.dart';
import '../Models/User.dart';
import '../preferences.dart';
import 'ProfileScreen.dart';
import 'SubjectDetailScreen.dart';

class StudentHomeScreen extends StatefulWidget {
  User user;

  StudentHomeScreen(this.user);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool isLoading = false;

  List<Subject> subjects = [];

  String error = "";

  int _selectedBottomNavigationItemIndex = 0;
  String appBarTitle = "Home";

  getListOfSubjects() async {
    setState(() {
      isLoading = true;
      error = "";
      subjects.clear();
    });
    try {
      subjects = await StudentHomeScreenService.get_subjects_list_per_student();
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst("Exception: ", "");
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget buildHomeBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (subjects.isEmpty) {
      if (error.isEmpty) {
        return const Center(
          child: Text("No subjects found"),
        );
      } else {
        return Center(
          child: Text(error),
        );
      }
    } else {
      switch (_selectedBottomNavigationItemIndex) {
        case 0:
          setState(() {
            appBarTitle = "Home";
          });
          return buildHomeMainBody();
        case 1:
          setState(() {
            appBarTitle = "Attendance";
          });
          return AttendanceScreen(user: widget.user);
        case 2:
          setState(() {
            appBarTitle = "All Notices";
          });
          return NoticesScreen(
            semester_id: (subjects.first.semester?.id)!,
            user: widget.user,
          );
      }
      return buildHomeMainBody();
    }
  }

  Widget buildHomeMainBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          left: 15,
          right: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Subjects:",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectDetailScreen(
                          subject: subjects[index],
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  child: buildSubjectCard(subjects[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    getListOfSubjects();
  }

  renderImage() {
    if (widget.user.profilePic != "") {
      return CachedNetworkImage(
        imageUrl: widget.user.profilePic!,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(
          value: downloadProgress.progress,
          color: Colors.white,
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.account_circle, size: 35),
        width: 35,
        height: 35,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.account_circle, size: 35);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10.0, top: 10, bottom: 10),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                User user = await Preferences.getUser();
                print(user.name);
                widget.user = user;
                setState(() {});
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: renderImage(),
              ),
            ),
          )
        ],
      ),
      body: buildHomeBody(),
      bottomNavigationBar: !isLoading
          ? BottomNavigationBar(
              currentIndex: _selectedBottomNavigationItemIndex,
              onTap: (index) {
                setState(() {
                  _selectedBottomNavigationItemIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: "Attendance",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: "Notices",
                ),
              ],
            )
          : null,
    );
  }

  buildSubjectCard(Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xFFD3D3D3)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: subject.picUrl!,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) =>
                const Icon(Icons.account_circle, size: 35),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name ?? "",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  buildSubjectCardBadge(
                      subject.semester?.department?.name ?? ""),
                  const SizedBox(
                    width: 10,
                  ),
                  buildSubjectCardBadge(subject.semester?.name ?? "")
                ],
              )
            ],
          ),
        )
      ]),
    );
  }

  buildSubjectCardBadge(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
