import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/Models/Subject.dart';
import 'package:lms_app/Services/NoticeService.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:validatorless/validatorless.dart';

import '../../Models/FileData.dart';
import '../../Models/Notice.dart';

class AddNoticeScreen extends StatefulWidget {
  final String semester_id;

  const AddNoticeScreen(this.semester_id, {Key? key}) : super(key: key);

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  bool isLoading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<PlatformFile> pickedFiles = [];

  final type_of_notice = ['Announcement', 'Timetable', 'Result'];
  String _currentSelectedValue = "Announcement";

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Notice"),
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
                if (formKey.currentState!.validate()) {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    Notice notice = Notice(
                      title: titleController.text,
                      description: descriptionController.text,
                      semester: widget.semester_id,
                      files: [],
                      type: _currentSelectedValue,
                    );
                    final storage = FirebaseStorage.instance;
                    String fcs_path = "";
                    for (var file in pickedFiles) {
                      fcs_path =
                          "notices/${DateTime.now().toIso8601String()}.${file.extension}";
                      TaskSnapshot task =
                          await storage.ref(fcs_path).putFile(File(file.path!));
                      if (task.state == TaskState.error) {
                        print("An error occurred");
                      } else {
                        String download_url = await task.ref.getDownloadURL();
                        notice.files?.add(
                          FileData(
                            nameOfFile: file.name,
                            typeOfFile: ".${file.extension}",
                            sizeOfFile: file.size,
                            downloadUrl: download_url,
                            fcsPath: fcs_path,
                          ),
                        );
                      }
                    }
                    Notice createdNotice = await NoticeService.create_notice(
                        notice);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Notice Created Successfully"),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                      titleController.text = "";
                      descriptionController.text = "";
                      pickedFiles.clear();
                    });
                    Navigator.pop(context, createdNotice);
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString().replaceFirst("Exception: ", "")),
                    ));
                    setState(() {
                      isLoading = false;
                    });
                  }
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
                        3, 'Title should be atleast contain 3 characters'),
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
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(
                  height: 18,
                ),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                          hintText: 'Please select type of notice',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      isEmpty: _currentSelectedValue == '',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentSelectedValue,
                          isDense: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              _currentSelectedValue =
                                  newValue ?? "Announcement";
                            });
                          },
                          items: type_of_notice.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 18,
                ),
                ListView.builder(
                  itemCount: pickedFiles.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => buildFileCard(
                    pickedFiles[index],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true);

                    if (result != null) {
                      pickedFiles.addAll(result.files);
                      print(pickedFiles.length);
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
                pickedFiles.remove(file);
              });
            },
            icon: const Icon(Icons.delete_rounded),
          )
        ],
      ),
    );
  }
}
