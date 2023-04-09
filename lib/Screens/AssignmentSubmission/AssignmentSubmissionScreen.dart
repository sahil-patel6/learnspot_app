import 'package:file_icon/file_icon.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:lms_app/Models/AssignmentSubmission.dart';
import 'package:lms_app/utils/showConfirmationDialog.dart';
import 'package:open_file_plus/open_file_plus.dart';

import '../../Models/Assignment.dart';
import '../../Models/FileData.dart';
import '../../Models/User.dart';
import '../../Services/AssignmentSubmissionService.dart';
import '../../utils/showLoaderDialog.dart';
import 'AddAssignmentSubmissionScreen.dart';
import 'UpdateAssignmentSubmission.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final Assignment assignment;
  final User user;

  const AssignmentSubmissionScreen(
      {Key? key, required this.assignment, required this.user})
      : super(key: key);

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  bool isLoading = false;
  String error = "";

  List<AssignmentSubmission> assignment_submissions = [];

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      assignment_submissions.clear();
    });
    try {
      assignment_submissions =
          await AssignmentSubmissionService.get_assignment_submissions(
              widget.assignment.id!);
      print(assignment_submissions);
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

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (assignment_submissions.isEmpty) {
        if (error.isEmpty) {
          return const Center(
            child: Text("No assignment submissions found"),
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
            itemCount: assignment_submissions.length,
            itemBuilder: (context, index) {
              return buildAssignmentSubmissionCard(
                  assignment_submissions[index]);
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
        title: Text(
          widget.user.type_of_user == "Teacher"
              ? "All Assignment Submissions"
              : "Your Assignment Submission",
        ),
      ),
      body: buildBody(),
      floatingActionButton: widget.user.type_of_user == "Student" &&
              !isLoading &&
              assignment_submissions.isEmpty
          ? FloatingActionButton(
              onPressed: () async {
                AssignmentSubmission? assignment_submission =
                    await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAssignmentSubmissionScreen(
                      assignment: widget.assignment,
                      user: widget.user,
                    ),
                  ),
                );
                if (assignment_submission != null) {
                  setState(() {
                    assignment_submissions.add(assignment_submission);
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  buildAssignmentSubmissionCardRow(String title, String text) {
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

  buildAssignmentSubmissionCard(AssignmentSubmission assignment_submission) {
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
          buildAssignmentSubmissionCardRow(
              "Comments:  ", assignment_submission.comments!),
          const SizedBox(
            height: 10,
          ),
          buildAssignmentSubmissionCardRow(
            "Submission Date:  ",
            DateFormat("dd MMM, yyyy, HH:mm").format(
              DateTime.parse(
                assignment_submission.submissionDate!,
              ).toLocal(),
            ),
          ),
          if (widget.user.type_of_user != "Student")
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                buildAssignmentSubmissionCardRow(
                  "Submitted By:  ",
                  assignment_submission.student?.name ?? "",
                ),
                const SizedBox(
                  height: 10,
                ),
                buildAssignmentSubmissionCardRow(
                  "Roll No:  ",
                  assignment_submission.student?.rollNumber ?? "",
                ),
              ],
            ),
          const SizedBox(
            height: 10,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: assignment_submission.submission?.length,
            itemBuilder: (context, index) => Column(
              children: [
                buildFileCard(
                  assignment_submission.submission![index],
                ),
              ],
            ),
          ),
          if (widget.user.type_of_user == "Student")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    AssignmentSubmission? updatedAssignmentSubmission =
                        await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateAssignmentSubmissionScreen(
                          assignment_submission: assignment_submission,
                        ),
                      ),
                    );
                    if (updatedAssignmentSubmission != null) {
                      setState(() {
                        assignment_submission = updatedAssignmentSubmission;
                      });
                    }
                  },
                  child: const Text("Update"),
                ),
                DeleteAssignmentSubmissionButton(
                    assignment_submission, removeAssignmentSubmission),
              ],
            )
        ],
      ),
    );
  }

  removeAssignmentSubmission(AssignmentSubmission assignment_submission) {
    setState(() {
      assignment_submissions.remove(assignment_submission);
    });
  }

  buildFileCard(FileData assignment_submission_file) {
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
                    .getSingleFile(assignment_submission_file.downloadUrl!);
                Navigator.pop(context);
                OpenFile.open(file.path);
              },
              child: Row(
                children: [
                  FileIcon(
                    ".${assignment_submission_file.typeOfFile}",
                    size: 45,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment_submission_file.nameOfFile ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(
                          filesize(assignment_submission_file.sizeOfFile),
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

class DeleteAssignmentSubmissionButton extends StatefulWidget {
  AssignmentSubmission assignment_submission;
  Function removeAssignmentSubmission;

  DeleteAssignmentSubmissionButton(
      this.assignment_submission, this.removeAssignmentSubmission,
      {Key? key})
      : super(key: key);

  @override
  State<DeleteAssignmentSubmissionButton> createState() =>
      _DeleteAssignmentSubmissionButtonState();
}

class _DeleteAssignmentSubmissionButtonState
    extends State<DeleteAssignmentSubmissionButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !isLoading
          ? () async {
              if (await showConfirmationDialog(context) ?? false) {
                setState(() {
                  isLoading = true;
                });
                try {
                  String response = await AssignmentSubmissionService
                      .delete_assignment_submission(
                          widget.assignment_submission.id!);
                  print(response);
                  widget
                      .removeAssignmentSubmission(widget.assignment_submission);
                  widget.assignment_submission.submission
                      ?.forEach((file) async {
                    await DefaultCacheManager().removeFile(file.downloadUrl!);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response),
                    ),
                  );
                } catch (e) {
                  print(e.toString().replaceFirst("Exception: ", ""));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString().replaceFirst("Exception: ", "")),
                  ));
                }
                setState(() {
                  isLoading = false;
                });
              }
            }
          : () {},
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
