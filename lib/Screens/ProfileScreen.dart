import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lms_app/Services/ProfileService.dart';

import '../Models/User.dart';
import '../preferences.dart';
import 'SplashScreen.dart';
import 'UpdateProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;

  late User? user;

  String error = "";

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      user = null;
    });
    try {
      user = await ProfileService.get_profile();
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
    if (user != null && user?.profilePic != "") {
      return CachedNetworkImage(
        imageUrl: user!.profilePic!,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) =>
            const Icon(Icons.account_circle, size: 200),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.account_circle, size: 200);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          if (user != null)
            IconButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdateProfileScreen(user!)));
                user = await Preferences.getUser();
                print(user?.name);
                setState(() {});
              },
              icon: const Icon(Icons.edit),
            )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : user == null
              ? const Center(child: Text("An error occurred"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 18,
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: renderImage(),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      buildContainer("Name:", user?.name ?? ""),
                      buildContainer("Email:", user?.email ?? ""),
                      if (user?.type_of_user == "Student")
                        buildContainer("Roll Number:", user?.roll_number ?? ""),
                      buildContainer("Phone:", user?.phone ?? ""),
                      buildContainer("Bio:", user?.bio ?? ""),
                      buildContainer("Address:", user?.address ?? ""),
                      ElevatedButton(
                        onPressed: () async {
                          await Preferences.removeUser();
                          await DefaultCacheManager().emptyCache();
                          // ignore: use_build_context_synchronously
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SplashScreen()),
                              (route) => false);
                        },
                        child: const Text("Log out"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
    );
  }

  buildContainer(String title, String text) {
    return Container(
      width: MediaQuery.of(context).size.width - 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFD3D3D3),
      ),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
