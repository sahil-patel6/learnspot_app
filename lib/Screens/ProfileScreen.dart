import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lms_app/Services/ProfileService.dart';
import 'package:validatorless/validatorless.dart';

import '../Models/User.dart';
import '../preferences.dart';
import '../utils/showConfirmationDialog.dart';
import 'SplashScreen.dart';
import 'UpdateProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool isLogoutLoading = false;

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
    getData();
  }

  renderImage() {
    if (user != null && user?.profilePic != "") {
      return CachedNetworkImage(
        imageUrl: user!.profilePic!,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(
          value: downloadProgress.progress,
          color: Colors.white,
        ),
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

  updatePassword() {
    showDialog(
      context: context,
      builder: (ctx) {
        String errorMessage = "";
        final formKey = GlobalKey<FormState>();
        TextEditingController currentPasswordController =
            TextEditingController();
        TextEditingController newPasswordController = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setState) {
            setErrorMessage(String error) {
              print("SETERROR");
              setState(() {
                errorMessage = error.replaceFirst("Exception: ", "");
              });
              print(errorMessage);
            }

            return AlertDialog(
              title: const Text("Update Password"),
              actions: [
                UpdatePasswordButton(
                  user!,
                  formKey,
                  currentPasswordController,
                  newPasswordController,
                  setErrorMessage,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                )
              ],
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                    if (errorMessage.isNotEmpty)
                      const SizedBox(
                        height: 18,
                      ),
                    TextFormField(
                      controller: currentPasswordController,
                      validator: Validatorless.multiple([
                        Validatorless.required('Current Password is required'),
                        Validatorless.min(8,
                            'Curent Password should atleast contain 8 characters'),
                      ]),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Current Password:",
                        labelText: "Current Password:",
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: newPasswordController,
                      validator: Validatorless.multiple([
                        Validatorless.required('Current Password is required'),
                        Validatorless.min(8,
                            'Curent Password should atleast contain 8 characters'),
                      ]),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "New Password:",
                        labelText: "New Password:",
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                        onPressed: updatePassword,
                        child: const Text(
                          "Update Password",
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      ElevatedButton(
                        onPressed: !isLogoutLoading
                            ? () async {
                                // ignore: use_build_context_synchronously
                                if (await showConfirmationDialog(context) ??
                                    false) {
                                  try {
                                    setState(() {
                                      isLogoutLoading = true;
                                    });
                                    String message =
                                        await ProfileService.logout();
                                    await Preferences.removeUser();
                                    await DefaultCacheManager().emptyCache();

                                    setState(() {
                                      isLogoutLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Logged out Successfully"),
                                      ),
                                    );
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SplashScreen()),
                                        (route) => false);
                                  } catch (e) {
                                    print(e.toString());
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(e
                                          .toString()
                                          .replaceFirst("Exception: ", "")),
                                    ));
                                    setState(() {
                                      isLogoutLoading = false;
                                    });
                                  }
                                  setState(() {
                                    isLogoutLoading = false;
                                  });
                                }
                              }
                            : () {},
                        child: isLogoutLoading
                            ? Container(
                                height: 20,
                                width: 20,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Log out"),
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

class UpdatePasswordButton extends StatefulWidget {
  User user;
  GlobalKey<FormState> formkey;
  TextEditingController currentPassword;
  TextEditingController newPassword;
  Function setErrorMessage;

  UpdatePasswordButton(this.user, this.formkey, this.currentPassword,
      this.newPassword, this.setErrorMessage,
      {Key? key})
      : super(key: key);

  @override
  State<UpdatePasswordButton> createState() => _UpdatePasswordButtonState();
}

class _UpdatePasswordButtonState extends State<UpdatePasswordButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !isLoading
          ? () async {
              try {
                if (widget.formkey.currentState!.validate() &&
                    (await showConfirmationDialog(context) ?? false)) {
                  setState(() {
                    isLoading = true;
                  });
                  User user = await ProfileService.update_password(widget.user,
                      widget.currentPassword.text, widget.newPassword.text);
                  print(user);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password Updated Successfully"),
                    ),
                  );
                }
              } catch (e) {
                print(e.toString().replaceFirst("Exception: ", ""));
                widget.setErrorMessage(
                    e.toString().replaceFirst("Exception: ", ""));
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //   content: Text(e.toString().replaceFirst("Exception: ", "")),
                // ));
              }
              setState(() {
                isLoading = false;
              });
            }
          : () {},
      child: isLoading
          ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : const Text("Update Password"),
    );
  }
}
