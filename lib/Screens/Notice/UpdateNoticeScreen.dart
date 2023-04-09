import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lms_app/Services/NoticeService.dart';
import 'package:lms_app/utils/showLoaderDialog.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:validatorless/validatorless.dart';

import '../../Models/FileData.dart';
import '../../Models/Notice.dart';
import '../../utils/showConfirmationDialog.dart';

class UpdateNoticeScreen extends StatefulWidget {
  final Notice notice;

  const UpdateNoticeScreen(this.notice, {Key? key}) : super(key: key);

  @override
  State<UpdateNoticeScreen> createState() => _UpdateNoticeScreenState();
}

class _UpdateNoticeScreenState extends State<UpdateNoticeScreen> {
  bool isLoading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<PlatformFile> _pickedFiles = [];
  List<FileData> deletedFiles = [];

  final type_of_notice = ['Announcement', 'Timetable', 'Result'];
  String _currentSelectedValue = "Announcement";

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.notice.title ?? "";
    descriptionController.text = widget.notice.description ?? "";
    _currentSelectedValue = widget.notice.type ?? "Announcement";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Notice"),
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
                if (formKey.currentState!.validate()&&
                    (await showConfirmationDialog(context) ?? false)) {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    final storage = FirebaseStorage.instance;
                    for (var deletedFile in deletedFiles) {
                      await storage.ref(deletedFile.fcsPath).delete();
                    }
                    widget.notice.title = titleController.text;
                    widget.notice.description = descriptionController.text;

                    String fcs_path = "";
                    for (var file in _pickedFiles) {
                      fcs_path =
                          "notices/${DateTime.now().toIso8601String()}.${file.extension}";
                      TaskSnapshot task =
                          await storage.ref(fcs_path).putFile(File(file.path!));
                      if (task.state == TaskState.error) {
                        print("An error occurred");
                      } else {
                        String downloadUrl = await task.ref.getDownloadURL();
                        widget.notice.files?.add(
                          FileData(
                            nameOfFile: file.name,
                            typeOfFile: ".${file.extension}",
                            sizeOfFile: file.size,
                            downloadUrl: downloadUrl,
                            fcsPath: fcs_path,
                          ),
                        );
                      }
                    }
                    Notice updatedNotice =
                        await NoticeService.update_notice(widget.notice);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Notice Updated Successfully"),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context, updatedNotice);
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString().replaceFirst("Exception: ", "")),
                    ));
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

                /// displaying list of files we got from Notice screen
                ListView.builder(
                  itemCount: widget.notice.files?.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => buildFileCard(
                    noticeFile: widget.notice.files![index],
                  ),
                ),

                /// displaying the picked files which the user used the add files button to pick it from phone storage
                ListView.builder(
                  itemCount: _pickedFiles.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => buildFileCard(
                    file: _pickedFiles[index],
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

  buildFileCard({PlatformFile? file, FileData? noticeFile}) {
    String name_of_file = "";
    String size_of_file = "";
    String type_of_file = "";
    if (file != null) {
      name_of_file = file.name;
      size_of_file = filesize(file.size);
      type_of_file = ".${file.extension}";
    } else {
      name_of_file = noticeFile?.nameOfFile ?? "";
      size_of_file = filesize(noticeFile?.sizeOfFile);
      type_of_file = noticeFile?.typeOfFile ?? "";
    }
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
                if (file != null) {
                  OpenFile.open(file.path);
                } else if (noticeFile != null) {
                  showLoaderDialog(context);
                  File file = await DefaultCacheManager()
                      .getSingleFile(noticeFile.downloadUrl!);
                  Navigator.pop(context);
                  OpenFile.open(file.path);
                } else {
                  print("An error occurred while opening the file");
                }
              },
              child: Row(
                children: [
                  FileIcon(
                    type_of_file,
                    size: 45,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name_of_file,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(
                          size_of_file,
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
                if (file != null) {
                  _pickedFiles.remove(file);
                } else {
                  widget.notice.files?.remove(noticeFile);
                  deletedFiles.add(noticeFile!);
                }
              });
            },
            icon: const Icon(Icons.delete_rounded),
          )
        ],
      ),
    );
  }
}
