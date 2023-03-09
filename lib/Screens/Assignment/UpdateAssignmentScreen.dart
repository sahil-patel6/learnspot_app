import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:lms_app/Models/Assignment.dart';
import 'package:lms_app/Services/AssignmentService.dart';
import 'package:lms_app/utils/showLoaderDialog.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:validatorless/validatorless.dart';

import '../../Models/Assignment.dart';
import '../../Models/FileData.dart';

class UpdateAssignmentScreen extends StatefulWidget {
  final Assignment assignment;

  const UpdateAssignmentScreen({
    Key? key,
    required this.assignment,
  }) : super(key: key);

  @override
  State<UpdateAssignmentScreen> createState() => _UpdateAssignmentScreenState();
}

class _UpdateAssignmentScreenState extends State<UpdateAssignmentScreen> {
  bool isLoading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  DateTime? dueDate;
  bool isSubmissionAllowed = true;

  List<PlatformFile> _pickedFiles = [];
  List<FileData> deletedFiles = [];

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.assignment.title ?? "";
    descriptionController.text = widget.assignment.description ?? "";
    marksController.text = widget.assignment.marks.toString();
    isSubmissionAllowed = widget.assignment.isSubmissionAllowed ?? true;
    dueDate =
        DateTime.parse(widget.assignment.dueDate.toString()).toLocal();
    dateController.text = dueDate.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Assignment"),
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
                    DateTime dueDate = DateFormat("yyyy-MM-dd HH:mm")
                        .parse(dateController.text);
                    print(dueDate.toUtc().toIso8601String());
                    if (dueDate.isBefore(
                      DateTime.now().add(
                        const Duration(minutes: 29),
                      ),
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Assignment Due Date should have atleast 30 minutes time"),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });

                    final storage = FirebaseStorage.instance;
                    for (var deletedFile in deletedFiles) {
                      await storage.ref(deletedFile.fcsPath).delete();
                    }
                    widget.assignment.title = titleController.text;
                    widget.assignment.description = descriptionController.text;
                    widget.assignment.marks = int.parse(marksController.text);
                    widget.assignment.isSubmissionAllowed = isSubmissionAllowed;
                    widget.assignment.dueDate =
                        dueDate.toUtc().toIso8601String();
                    String fcs_path = "";
                    for (var file in _pickedFiles) {
                      fcs_path =
                          "assignments/${DateTime.now().toIso8601String()}.${file.extension}";
                      TaskSnapshot task =
                          await storage.ref(fcs_path).putFile(File(file.path!));
                      if (task.state == TaskState.error) {
                        print("An error occurred");
                      } else {
                        String downloadUrl = await task.ref.getDownloadURL();
                        widget.assignment.assignmentQuestionFiles?.add(
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
                    Assignment updatedAssignment =
                        await AssignmentService.update_assignment(
                            widget.assignment);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Assignment Updated Successfully"),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context, updatedAssignment);
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
                TextFormField(
                  controller: marksController,
                  validator: Validatorless.multiple([
                    Validatorless.required('Marks is required'),
                    Validatorless.number('Please Enter a valid number ')
                  ]),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Marks:",
                    labelText: "Marks:",
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 18,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFD3D3D3)),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Submission Allowed: ", style: TextStyle(fontSize: 18),),
                      Switch(
                        value: isSubmissionAllowed,
                        onChanged: (val) {
                          setState(() {
                            isSubmissionAllowed = val;
                          });
                        },
                      )
                    ],
                  ),
                ),
                DateTimePicker(
                  type: DateTimePickerType.dateTime,
                  dateMask: 'dd MMM, yyyy, HH:mm',
                  firstDate: dueDate,
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  icon: const Icon(Icons.event),
                  dateLabelText: 'Due Date:',
                  controller: dateController,
                  // selectableDayPredicate: (date) {
                  //   // Disable weekend days to select from the calendar
                  //   if (date.weekday == 6 || date.weekday == 7) {
                  //     return false;
                  //   }
                  //   return true;
                  // },
                  onChanged: (val) => print(val),
                  // validator: (val) {
                  //   print(val);
                  //   if (val != null) {
                  //     DateTime dueDate =
                  //         DateFormat("yyyy-MM-dd HH:mm").parse(val);
                  //     print("DATE ${dueDate.toUtc().toIso8601String()}");
                  //     DateTime originalDueDate =
                  //         DateTime.parse(widget.assignment.dueDate.toString())
                  //             .toLocal();
                  //
                  //     if (dueDate.isBefore(originalDueDate) ||
                  //         dueDate.isBefore(DateTime.now()
                  //             .add(const Duration(minutes: 29)))) {
                  //       return "Due Date should be atleast 30 minutes";
                  //     }
                  //   }
                  //   return null;
                  // },
                  // onSaved: (val) => print(val),
                ),
                const SizedBox(
                  height: 18,
                ),

                /// displaying list of files we got from assignment screen
                ListView.builder(
                  itemCount: widget.assignment.assignmentQuestionFiles?.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => buildFileCard(
                    assignmentQuestionFile:
                        widget.assignment.assignmentQuestionFiles![index],
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

  buildFileCard({PlatformFile? file, FileData? assignmentQuestionFile}) {
    String name_of_file = "";
    String size_of_file = "";
    String type_of_file = "";
    if (file != null) {
      name_of_file = file.name;
      size_of_file = filesize(file.size);
      type_of_file = ".${file.extension}";
    } else {
      name_of_file = assignmentQuestionFile?.nameOfFile ?? "";
      size_of_file = filesize(assignmentQuestionFile?.sizeOfFile);
      type_of_file = assignmentQuestionFile?.typeOfFile ?? "";
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
                } else if (assignmentQuestionFile != null) {
                  showLoaderDialog(context);
                  File file = await DefaultCacheManager()
                      .getSingleFile(assignmentQuestionFile.downloadUrl!);
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
                  widget.assignment.assignmentQuestionFiles
                      ?.remove(assignmentQuestionFile);
                  deletedFiles.add(assignmentQuestionFile!);
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
