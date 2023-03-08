import 'package:file_icon/file_icon.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:lms_app/Models/Assignment.dart';
import 'package:lms_app/Models/Subject.dart';
import 'package:lms_app/Screens/Assignment/AddAssignmentScreen.dart';
import 'package:lms_app/Services/AssignmentService.dart';
import 'package:lms_app/preferences.dart';
import 'package:open_file_plus/open_file_plus.dart';

import '../../Models/FileData.dart';
import '../../Models/User.dart';
import '../../utils/showLoaderDialog.dart';
import 'UpdateAssignmentScreen.dart';

class AssignmentsScreen extends StatefulWidget {
  final Subject subject;

  const AssignmentsScreen({Key? key, required this.subject}) : super(key: key);

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  bool isLoading = false;
  String error = "";

  User? user;
  List<Assignment> assignments = [];

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      assignments.clear();
    });
    try {
      user = await Preferences.getUser();
      assignments = await AssignmentService.get_assignments(widget.subject.id!);
      print(assignments);
    } catch (e) {
      setState(() {
        error = e.toString();
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

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (assignments.isEmpty) {
        if (error.isEmpty) {
          return const Center(
            child: Text("No assignments found"),
          );
        } else {
          return Center(
            child: Text(error),
          );
        }
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 18, right: 18),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              return buildAssignmentCard(assignments[index]);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Assignments"),
      ),
      body: buildBody(),
      floatingActionButton: user != null && user?.type_of_user == "Teacher" ? FloatingActionButton(
        onPressed: () async {
          Assignment? assignment = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAssignmentScreen(widget.subject),
            ),
          );
          if (assignment != null) {
            setState(() {
              assignments.add(assignment);
            });
          }
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  buildAssignmentCardRow(String title, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  buildAssignmentCard(Assignment assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFD3D3D3)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAssignmentCardRow("Title:  ", assignment.title!),
          const SizedBox(
            height: 10,
          ),
          buildAssignmentCardRow("Description:  ", assignment.description!),
          const SizedBox(
            height: 10,
          ),
          buildAssignmentCardRow(
            "Due Date:  ",
            DateFormat("dd MMM, yyyy, HH:mm").format(
              DateTime.parse(
                assignment.dueDate!,
              ).toLocal(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          buildAssignmentCardRow(
            "Submission allowed:  ",
            assignment.isSubmissionAllowed! ? "YES" : "NO",
          ),
          const SizedBox(
            height: 10,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: assignment.assignmentQuestionFiles?.length,
            itemBuilder: (context, index) => Column(
              children: [
                buildFileCard(
                  assignment.assignmentQuestionFiles![index],
                ),
              ],
            ),
          ),
          if (user?.type_of_user == "Teacher")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Assignment? updatedAssignment = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateAssignmentScreen(widget.subject, assignment),
                      ),
                    );
                    if (updatedAssignment != null) {
                      setState(() {
                        assignment = updatedAssignment;
                      });
                    }
                  },
                  child: const Text("Update"),
                ),
                DeleteAssignmentButton(assignment, removeAssignment),
              ],
            )
        ],
      ),
    );
  }

  removeAssignment(Assignment assignment) {
    setState(() {
      assignments.remove(assignment);
    });
  }

  buildFileCard(FileData assignmentQuestionFile) {
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
                showLoaderDialog(context);
                var file = await DefaultCacheManager()
                    .getSingleFile(assignmentQuestionFile.downloadUrl!);
                Navigator.pop(context);
                OpenFile.open(file.path);
              },
              child: Row(
                children: [
                  FileIcon(
                    ".${assignmentQuestionFile.typeOfFile}",
                    size: 45,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignmentQuestionFile.nameOfFile ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(
                          filesize(assignmentQuestionFile.sizeOfFile),
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
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
          )
        ],
      ),
    );
  }
}

class DeleteAssignmentButton extends StatefulWidget {
  Assignment assignment;
  Function removeAssignment;

  DeleteAssignmentButton(this.assignment, this.removeAssignment, {Key? key})
      : super(key: key);

  @override
  State<DeleteAssignmentButton> createState() => _DeleteAssignmentButtonState();
}

class _DeleteAssignmentButtonState extends State<DeleteAssignmentButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });
        try {
          String response =
              await AssignmentService.delete_assignment(widget.assignment.id!);
          print(response);
          widget.removeAssignment(widget.assignment);
          widget.assignment.assignmentQuestionFiles?.forEach((file) async {
            await DefaultCacheManager().removeFile(file.downloadUrl!);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response),
            ),
          );
        } catch (e) {
          print(e.toString());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
        }
        setState(() {
          isLoading = false;
        });
      },
      child: isLoading
          ? Center(
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          : const Text("Delete"),
    );
  }
}
