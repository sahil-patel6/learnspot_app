import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms_app/Models/FileData.dart';
import 'package:lms_app/Models/Subject.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:validatorless/validatorless.dart';

import '../../Models/Assignment.dart';
import '../../Services/AssignmentService.dart';

class AddAssignmentScreen extends StatefulWidget {
  final Subject subject;

  const AddAssignmentScreen({Key? key, required this.subject})
      : super(key: key);

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  bool isLoading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController dateController = TextEditingController(
      text: DateTime.now().add(const Duration(minutes: 30)).toString());
  bool isSubmissionAllowed = true;

  List<PlatformFile> pickedFiles = [];

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assignment"),
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
                    // print(dateController.text);
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
                    print(dueDate.toUtc().toIso8601String());
                    Assignment assignment = Assignment(
                      title: titleController.text,
                      description: descriptionController.text,
                      subject: widget.subject.id,
                      dueDate: dueDate.toUtc().toIso8601String(),
                      marks: int.parse(marksController.text),
                      isSubmissionAllowed: isSubmissionAllowed,
                      assignmentQuestionFiles: [],
                    );
                    final storage = FirebaseStorage.instance;
                    String fcs_path = "";
                    for (var file in pickedFiles) {
                      fcs_path =
                          "assignments/${DateTime.now().toIso8601String()}.${file.extension}";
                      TaskSnapshot task =
                          await storage.ref(fcs_path).putFile(File(file.path!));
                      if (task.state == TaskState.error) {
                        print("An error occurred");
                      } else {
                        String download_url = await task.ref.getDownloadURL();
                        assignment.assignmentQuestionFiles?.add(
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
                    Assignment createdAssignment =
                        await AssignmentService.create_assignment(assignment);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Assignment Created Successfully"),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                      titleController.text = "";
                      descriptionController.text = "";
                      pickedFiles.clear();
                    });
                    Navigator.pop(context, createdAssignment);
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
                  firstDate: DateTime.now().add(
                    const Duration(minutes: 30),
                  ),
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
                  validator: (val) {
                    print(val);
                    if (val != null) {
                      DateTime dueDate =
                          DateFormat("yyyy-MM-dd HH:mm").parse(val);
                      print("DATE ${dueDate.toUtc().toIso8601String()}");
                      if (dueDate.isBefore(
                          DateTime.now().add(const Duration(minutes: 29)))) {
                        return "Due Date should be atleast 30 minutes";
                      }
                    }
                    return null;
                  },
                  autovalidate: false,
                  // onSaved: (val) => print(val),
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
