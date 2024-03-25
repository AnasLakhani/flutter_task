import 'package:flutter/material.dart';
import 'package:flutter_task/app/controllers/main_controllers.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../../utils/my_utils.dart';

class LinkTabWidgets extends GetView<MainController> {
  const LinkTabWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
        init: MainController(),
        builder: (controller) {
          return ListView.builder(
            itemCount: controller.links.value.length,
            itemBuilder: (context, index) {
              final link = controller.links.value[index];
              return ListTile(
                leading: Icon(MyUtils.getDomainIcon(link.url)),
                subtitle: Text(link.title.isEmpty ? link.url : link.title),
                title: Text(link.url),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        controller.editLink(link);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        controller.deleteLink(index, link);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
