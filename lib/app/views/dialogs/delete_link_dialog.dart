import 'package:flutter/material.dart';
import 'package:flutter_task/app/adapter/link_adapter.dart';
import 'package:flutter_task/app/controllers/main_controllers.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class DeleteLinkDialog extends GetView<MainController> {
  final int index;
  final Link link;
  const DeleteLinkDialog({super.key, required this.index, required this.link});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure you want to delete this link?"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            controller.deleteTask(index, link);
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
