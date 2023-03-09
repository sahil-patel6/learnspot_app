import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lms_app/Services/AssignmentSubmissionService.dart';
import 'package:lms_app/utils/showLoaderDialog.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:validatorless/validatorless.dart';

import '../../Models/AssignmentSubmission.dart';
import '../../Models/FileData.dart';

class UpdateAssignmentSubmissionScreen extends StatefulWidget {
  final AssignmentSubmission assignment_submission;

  const UpdateAssignmentSubmissionScreen(
      {Key? key, required this.assignment_submission})
      : super(key: key);

  @override
  State<UpdateAssignmentSubmissionScreen> createState() =>
      _UpdateAssignmentSubmissionScreenState();
}

class _UpdateAssignmentSubmissionScreenState
    extends State<UpdateAssignmentSubmissionScreen> {
  bool isLoading = false;

  TextEditingController commentsController = TextEditingController();

  List<PlatformFile> _pickedFiles = [];
  List<FileData> deletedFiles = [];

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    commentsController.text = widget.assignment_submission.comments ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Submission"),
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
                    (_pickedFiles.isNotEmpty ||
                        (widget
                            .assignment_submission.submission?.isNotEmpty)!)) {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    final storage = FirebaseStorage.instance;
                    for (var deletedFile in deletedFiles) {
                      await storage.ref(deletedFile.fcsPath).delete();
                    }
                    widget.assignment_submission.comments =
                        commentsController.text;
                    widget.assignment_submission.submissionDate =
                        DateTime.now().toUtc().toIso8601String();
                    String fcs_path = "";
                    for (var file in _pickedFiles) {
                      fcs_path =
                          "assignment_submissions/${DateTime.now().toIso8601String()}.${file.extension}";
                      TaskSnapshot task =
                          await storage.ref(fcs_path).putFile(File(file.path!));
                      if (task.state == TaskState.error) {
                        print("An error occurred");
                      } else {
                        String downloadUrl = await task.ref.getDownloadURL();
                        widget.assignment_submission.submission?.add(
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
                    AssignmentSubmission updatedAssignmentSubmission =
                        await AssignmentSubmissionService
                            .update_assignment_submission(
                                widget.assignment_submission);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Assignment Submission Updated Successfully"),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context, updatedAssignmentSubmission);
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
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
                  controller: commentsController,
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
                const SizedBox(
                  height: 18,
                ),

                /// displaying list of files we got from Assignment Submission screen
                ListView.builder(
                  itemCount: widget.assignment_submission.submission?.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => buildFileCard(
                    assignmentSubmissionFile:
                        widget.assignment_submission.submission![index],
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

  buildFileCard({PlatformFile? file, FileData? assignmentSubmissionFile}) {
    String name_of_file = "";
    String size_of_file = "";
    String type_of_file = "";
    if (file != null) {
      name_of_file = file.name;
      size_of_file = filesize(file.size);
      type_of_file = ".${file.extension}";
    } else {
      name_of_file = assignmentSubmissionFile?.nameOfFile ?? "";
      size_of_file = filesize(assignmentSubmissionFile?.sizeOfFile);
      type_of_file = assignmentSubmissionFile?.typeOfFile ?? "";
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
                } else if (assignmentSubmissionFile != null) {
                  showLoaderDialog(context);
                  File file = await DefaultCacheManager()
                      .getSingleFile(assignmentSubmissionFile.downloadUrl!);
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
                  widget.assignment_submission.submission
                      ?.remove(assignmentSubmissionFile);
                  deletedFiles.add(assignmentSubmissionFile!);
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
