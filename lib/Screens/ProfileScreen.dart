import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Models/User.dart';
import '../preferences.dart';
import 'SplashScreen.dart';
import 'UpdateProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  User user;
  ProfileScreen(this.user, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  renderImage() {
    if (widget.user.profilePic != "") {
      return CachedNetworkImage(
        imageUrl: widget.user.profilePic!,
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
          IconButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateProfileScreen(widget.user)));
              User user = await Preferences.getUser();
              print(user.name);
              widget.user = user;
              setState(() {});
            },
            icon: const Icon(Icons.edit),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 18,),
          Align(
            alignment: Alignment.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: renderImage(),
            ),
          ),
          const SizedBox(height: 18,),
          buildContainer("Name:", widget.user.name ?? ""),
          buildContainer("Email:", widget.user.email ?? ""),
          buildContainer("Phone:", widget.user.phone ?? ""),
          buildContainer("Bio:", widget.user.bio ?? ""),
          buildContainer("Address:", widget.user.address ?? ""),
          ElevatedButton(
              onPressed: () async {
                await Preferences.removeUser();
                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()),
                    (route) => false);
              },
              child: const Text("Log out"))
        ],
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
