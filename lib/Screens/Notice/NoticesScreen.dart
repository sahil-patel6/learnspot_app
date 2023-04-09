import 'package:file_icon/file_icon.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:lms_app/Screens/Notice/UpdateNoticeScreen.dart';
import 'package:lms_app/Services/NoticeService.dart';
import 'package:open_file_plus/open_file_plus.dart';

import '../../Models/FileData.dart';
import '../../Models/Notice.dart';
import '../../Models/User.dart';
import '../../utils/showConfirmationDialog.dart';
import '../../utils/showLoaderDialog.dart';
import 'AddNoticeScreen.dart';

class NoticesScreen extends StatefulWidget {
  final String semester_id;
  final User user;

  const NoticesScreen({Key? key, required this.semester_id, required this.user})
      : super(key: key);

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  bool isLoading = false;
  String error = "";

  List<Notice> notices = [];

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      notices.clear();
    });
    try {
      notices = await NoticeService.get_notices(widget.semester_id);
      print(notices);
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
      if (notices.isEmpty) {
        if (error.isEmpty) {
          return const Center(
            child: Text("No notices found"),
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
            itemCount: notices.length,
            itemBuilder: (context, index) {
              return buildNoticeCard(notices[index]);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.user.type_of_user != "Student"
          ? AppBar(
              title: const Text("All Notices"),
            )
          : null,
      body: buildBody(),
      floatingActionButton: widget.user.type_of_user == "Teacher"
          ? FloatingActionButton(
              onPressed: () async {
                Notice? notice = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNoticeScreen(widget.semester_id),
                  ),
                );
                if (notice != null) {
                  setState(() {
                    notices.add(notice);
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  buildNoticeTypeCardBadge(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  buildNoticeCardRow(String title, String text, {bool type_badge = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        type_badge
            ? buildNoticeTypeCardBadge(text)
            : Flexible(
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

  buildNoticeCard(Notice notice) {
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
          buildNoticeCardRow("Title:  ", notice.title!),
          const SizedBox(
            height: 10,
          ),
          buildNoticeCardRow("Description:  ", notice.description!),
          const SizedBox(
            height: 10,
          ),
          buildNoticeCardRow(
            "Date:  ",
            DateFormat("dd MMM, yyyy, HH:mm").format(
              DateTime.parse(
                notice.date!,
              ).toLocal(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          buildNoticeCardRow(
            "Type:  ",
            notice.type!,
            type_badge: true,
          ),
          const SizedBox(
            height: 10,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: notice.files?.length,
            itemBuilder: (context, index) => Column(
              children: [
                buildFileCard(
                  notice.files![index],
                ),
              ],
            ),
          ),
          if (widget.user.type_of_user == "Teacher")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Notice? updatedNotice = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateNoticeScreen(notice),
                      ),
                    );
                    if (updatedNotice != null) {
                      setState(() {
                        notice = updatedNotice;
                      });
                    }
                  },
                  child: const Text("Update"),
                ),
                DeleteNoticeButton(notice, removeNotice),
              ],
            )
        ],
      ),
    );
  }

  removeNotice(Notice notice) {
    setState(() {
      notices.remove(notice);
    });
  }

  buildFileCard(FileData noticeFile) {
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
                    .getSingleFile(noticeFile.downloadUrl!);
                Navigator.pop(context);
                OpenFile.open(file.path);
              },
              child: Row(
                children: [
                  FileIcon(
                    ".${noticeFile.typeOfFile}",
                    size: 45,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noticeFile.nameOfFile ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(
                          filesize(noticeFile.sizeOfFile),
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

class DeleteNoticeButton extends StatefulWidget {
  Notice notice;
  Function removeNotice;

  DeleteNoticeButton(this.notice, this.removeNotice, {Key? key})
      : super(key: key);

  @override
  State<DeleteNoticeButton> createState() => _DeleteNoticeButtonState();
}

class _DeleteNoticeButtonState extends State<DeleteNoticeButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !isLoading? () async {
        if (await showConfirmationDialog(context) ?? false) {
          setState(() {
            isLoading = true;
          });
          try {
            String response =
                await NoticeService.delete_notice(widget.notice.id!);
            print(response);
            widget.removeNotice(widget.notice);
            widget.notice.files?.forEach((file) async {
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
      } : (){},
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
