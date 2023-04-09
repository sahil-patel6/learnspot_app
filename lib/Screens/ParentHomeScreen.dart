import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/Screens/ChildDetailScreen.dart';
import 'package:lms_app/Services/ParentHomeScreenService.dart';
import 'package:lms_app/utils/requestNotfificationsPermission.dart';

import '../Models/Student.dart';
import '../Models/User.dart';
import '../preferences.dart';
import 'ProfileScreen.dart';

class ParentHomeScreen extends StatefulWidget {
  User user;

  ParentHomeScreen(this.user);

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  bool isLoading = false;

  List<Student> children = [];

  String error = "";

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      children.clear();
    });
    try {
      children = await ParentHomeScreenService.get_students_by_parent();
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
    requestNotificationPermission();
    getData();
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
          : children.isEmpty
              ? error.isEmpty
                  ? const Center(
                      child: Text("No students Found"),
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
                          "Your Children:",
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
                          itemCount: children.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildDetailScreen(
                                      student: children[index],
                                      user: widget.user,
                                    ),
                                  ),
                                );
                              },
                              child: buildChildCard(children[index]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  buildChildCard(Student child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xFFD3D3D3)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: child.profilePic == ""
              ? const Icon(
                  Icons.account_box,
                  size: 100,
                )
              : CachedNetworkImage(
                  imageUrl: child.profilePic!,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                    value: downloadProgress.progress,
                    color: Colors.white,
                  ),
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
                child.name ?? "",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  buildSubjectCardBadge(child.semester?.department?.name ?? ""),
                  const SizedBox(
                    width: 10,
                  ),
                  buildSubjectCardBadge(child.semester?.name ?? "")
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
