import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:validatorless/validatorless.dart';

import '../Models/User.dart';
import '../Services/ProfileService.dart';
import '../preferences.dart';
import '../utils/showConfirmationDialog.dart';

class UpdateProfileScreen extends StatefulWidget {
  User user;

  UpdateProfileScreen(this.user, {super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  Uint8List? image;
  XFile? picked_image;

  initData() {
    setState(() {
      nameController.text = widget.user.name ?? "";
      emailController.text = widget.user.email ?? "";
      phoneController.text = widget.user.phone ?? "";
      bioController.text = widget.user.bio ?? "";
      addressController.text = widget.user.address ?? "";
    });
  }

  updateUserData() {
    widget.user.name = nameController.text;
    widget.user.email = emailController.text;
    widget.user.phone = phoneController.text;
    widget.user.bio = bioController.text;
    widget.user.address = addressController.text;
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  renderImage() {
    if (image != null) {
      return Image.memory(
        image!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
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
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update My Profile"),
        actions: [
          isLoading
              ? Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 10),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    print(await Preferences.getUser());
                    if (formKey.currentState!.validate() &&
                        (await showConfirmationDialog(context) ?? false)) {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        updateUserData();
                        String profile_pic = "";
                        String fcs_profile_pic_path = "";
                        if (image != null && picked_image != null) {
                          final storage = FirebaseStorage.instance;
                          if (widget.user.type_of_user == "Teacher") {
                            fcs_profile_pic_path =
                                "profile_pics/teachers/${picked_image?.name}";
                          } else if (widget.user.type_of_user == "Student") {
                            fcs_profile_pic_path =
                                "profile_pics/students/${picked_image?.name}";
                          } else {
                            fcs_profile_pic_path =
                                "profile_pics/parents/${picked_image?.name}";
                          }

                          TaskSnapshot task = await storage
                              .ref(fcs_profile_pic_path)
                              .putData(image!);
                          if (task.state == TaskState.error) {
                            print("An error occured");
                          } else {
                            if (widget.user.fcsProfilePicPath != "") {
                              await storage
                                  .ref(widget.user.fcsProfilePicPath)
                                  .delete();
                            }
                            widget.user.profilePic =
                                await task.ref.getDownloadURL();
                            widget.user.fcsProfilePicPath =
                                fcs_profile_pic_path;
                            print(widget.user.profilePic);
                            print(widget.user.fcsProfilePicPath);
                          }
                        }

                        User user =
                            await ProfileService.update_profile(widget.user);
                        // ignore: use_build_context_synchronously
                        print(user.name);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Profile Updated Successfully"),
                        ));
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              e.toString().replaceFirst("Exception: ", "")),
                        ));
                      }
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 18,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: InkWell(
                onTap: () async {
                  picked_image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  image = await picked_image?.readAsBytes();
                  setState(() {});
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: renderImage(),
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      validator: Validatorless.multiple([
                        Validatorless.required('Name is required'),
                        Validatorless.min(
                            3, 'Name should atleast contain 3 characters'),
                      ]),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Name:",
                        labelText: "Name:",
                      ),
                    ),
                    const SizedBox(height: 18),
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
                      controller: phoneController,
                      validator: Validatorless.multiple([
                        Validatorless.required('Phone is required'),
                        Validatorless.min(
                            10, 'Please Enter a valid Phone number'),
                      ]),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Phone:",
                        hintText: "Phone:",
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    TextFormField(
                      controller: bioController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Bio:",
                        hintText: "Bio:",
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Address:",
                        hintText: "Address:",
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
