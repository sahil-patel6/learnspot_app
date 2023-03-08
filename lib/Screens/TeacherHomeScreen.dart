import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../Models/Subject.dart';
import '../Models/User.dart';
import '../Services/TeacherHomeScreenService.dart';
import '../preferences.dart';
import 'ProfileScreen.dart';
import 'SubjectDetailScreen.dart';

class TeacherHomeScreen extends StatefulWidget {
  User user;

  TeacherHomeScreen(this.user);

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool isLoading = false;

  List<Subject> subjects = [];

  String error = "";

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      subjects.clear();
    });
    try {
      subjects = await TeacherHomeScreenService.get_subjects_list_for_teacher();
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

  renderImage() {
    if (widget.user.profilePic != "") {
      return CachedNetworkImage(
        imageUrl: widget.user.profilePic!,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
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
        title: const Text("Home"),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? error.isEmpty
                  ? const Center(
                      child: Text("No subjects Found"),
                    )
                  : Center(
                      child: Text(error),
                    )
              : SingleChildScrollView(
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
                ),
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
