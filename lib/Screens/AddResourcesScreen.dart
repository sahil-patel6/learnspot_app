import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/Models/Subject.dart';
import 'package:lms_app/Services/ResourceService.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:validatorless/validatorless.dart';

import '../Models/Resource.dart';

class AddResourcesScreen extends StatefulWidget {
  final Subject subject;

  const AddResourcesScreen(this.subject, {Key? key}) : super(key: key);

  @override
  State<AddResourcesScreen> createState() => _AddResourcesScreenState();
}

class _AddResourcesScreenState extends State<AddResourcesScreen> {
  bool isLoading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<PlatformFile> _pickedFiles = [];

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Resources"),
        actions: [
          if (isLoading)
            Center(
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 10),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    _pickedFiles.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                  });
                  Resource resource = Resource(
                    title: titleController.text,
                    description: descriptionController.text,
                    subject: widget.subject.id,
                    files: [],
                  );
                  final storage = FirebaseStorage.instance;
                  String fcs_path = "";
                  for (var file in _pickedFiles) {
                    fcs_path =
                        "resources/${DateTime.now().toIso8601String()}.${file.extension}";
                    TaskSnapshot task =
                        await storage.ref(fcs_path).putFile(File(file.path!));
                    if (task.state == TaskState.error) {
                      print("An error occurred");
                    } else {
                      String download_url = await task.ref.getDownloadURL();
                      resource.files?.add(
                        ResourceFile(
                          nameOfFile: file.name,
                          typeOfFile: ".${file.extension}",
                          sizeOfFile: file.size,
                          downloadUrl: download_url,
                          fcsPath: fcs_path,
                        ),
                      );
                    }
                  }
                  Resource createdResource =
                      await ResourceService.create_resource(resource);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Resource Created Successfully"),
                    ),
                  );
                  setState(() {
                    isLoading = false;
                    titleController.text = "";
                    descriptionController.text = "";
                    _pickedFiles.clear();
                  });
                  Navigator.pop(context,createdResource);
                }
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  validator: Validatorless.multiple([
                    Validatorless.required('Title is required'),
                    Validatorless.min(
                        3, 'Title should atleast contain 3 characters'),
                  ]),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Title:",
                    labelText: "Title:",
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: descriptionController,
                  validator: Validatorless.multiple([
                    Validatorless.required('Description is required'),
                    Validatorless.between(
                        10, 150, 'Please Enter between 10 and 150 characters')
                  ]),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Description:",
                    labelText: "Description:",
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                ListView.builder(
                  itemCount: _pickedFiles.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => buildFileCard(
                    _pickedFiles[index],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true);

                    if (result != null) {
                      _pickedFiles.addAll(result.files);
                      print(_pickedFiles.length);
                      setState(() {});
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: const Text("Add Files"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildFileCard(PlatformFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                OpenFile.open(file.path);
              },
              child: Row(
                children: [
                  FileIcon(
                    ".${file.extension}",
                    size: 45,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(
                          filesize(file.size),
                          style: const TextStyle(color: Colors.blueGrey),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _pickedFiles.remove(file);
              });
            },
            icon: const Icon(Icons.delete_rounded),
          )
        ],
      ),
    );
  }
}
