import 'package:flutter/material.dart';
import 'package:flutter_task/app/adapter/link_adapter.dart';
import 'package:flutter_task/app/controllers/main_controllers.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class LinkDialog extends GetView<MainController> {
  final Link? link;

  const LinkDialog({this.link, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.urlController,
            decoration: const InputDecoration(labelText: 'URL'),
          ),
          TextField(
            controller: controller.titleController,
            decoration:
                const InputDecoration(labelText: 'Custom Title (Optional)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (link == null) {
                controller.saveLink();
              } else {
                controller.updateLink(link!);
              }
            },
            child: Text(link != null ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }
}
