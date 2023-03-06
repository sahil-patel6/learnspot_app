import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
