import 'package:file_icon/file_icon.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lms_app/Models/Resource.dart';
import 'package:lms_app/Models/Subject.dart';
import 'package:lms_app/Services/ResourceService.dart';
import 'package:open_file_plus/open_file_plus.dart';

import '../../Models/FileData.dart';
import '../../Models/User.dart';
import '../../utils/showConfirmationDialog.dart';
import '../../utils/showLoaderDialog.dart';
import 'AddResourceScreen.dart';
import 'UpdateResourceScreen.dart';

class ResourcesScreen extends StatefulWidget {
  final Subject subject;
  final User user;

  const ResourcesScreen({Key? key, required this.subject, required this.user})
      : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  bool isLoading = false;
  String error = "";

  List<Resource> resources = [];

  getData() async {
    setState(() {
      isLoading = true;
      error = "";
      resources.clear();
    });
    try {
      resources = await ResourceService.get_resources(widget.subject.id!);
      print(resources);
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
      if (resources.isEmpty) {
        if (error.isEmpty) {
          return const Center(
            child: Text("No resources found"),
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
            itemCount: resources.length,
            itemBuilder: (context, index) {
              return buildResourceCard(resources[index]);
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
        title: const Text("All Resources"),
      ),
      body: buildBody(),
      floatingActionButton: widget.user.type_of_user == "Teacher"
          ? FloatingActionButton(
              onPressed: () async {
                Resource? resource = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddResourceScreen(
                      subject: widget.subject,
                    ),
                  ),
                );
                if (resource != null) {
                  setState(() {
                    resources.add(resource);
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  buildResourceCardRow(String title, String text) {
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

  buildResourceCard(Resource resource) {
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
          buildResourceCardRow("Title:  ", resource.title!),
          const SizedBox(
            height: 10,
          ),
          buildResourceCardRow("Description:  ", resource.description!),
          const SizedBox(
            height: 10,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: resource.files?.length,
            itemBuilder: (context, index) => Column(
              children: [
                buildFileCard(
                  resource.files![index],
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
                    Resource? updatedResource = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateResourceScreen(resource: resource),
                      ),
                    );
                    if (updatedResource != null) {
                      setState(() {
                        resource = updatedResource;
                      });
                    }
                  },
                  child: const Text("Update"),
                ),
                DeleteResourceButton(resource, removeResource),
              ],
            )
        ],
      ),
    );
  }

  removeResource(Resource resource) {
    setState(() {
      resources.remove(resource);
    });
  }

  buildFileCard(FileData resourceFile) {
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
                    .getSingleFile(resourceFile.downloadUrl!);
                Navigator.pop(context);
                OpenFile.open(file.path);
              },
              child: Row(
                children: [
                  FileIcon(
                    ".${resourceFile.typeOfFile}",
                    size: 45,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resourceFile.nameOfFile ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(
                          filesize(resourceFile.sizeOfFile),
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

class DeleteResourceButton extends StatefulWidget {
  Resource resource;
  Function removeResource;

  DeleteResourceButton(this.resource, this.removeResource, {Key? key})
      : super(key: key);

  @override
  State<DeleteResourceButton> createState() => _DeleteResourceButtonState();
}

class _DeleteResourceButtonState extends State<DeleteResourceButton> {
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
                  String response = await ResourceService.delete_resource(
                      widget.resource.id!);
                  print(response);
                  widget.removeResource(widget.resource);
                  widget.resource.files?.forEach((file) async {
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
          : (){},
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
