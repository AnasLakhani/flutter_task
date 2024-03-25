import 'package:flutter/material.dart';
import 'package:flutter_task/app/controllers/main_controllers.dart';
import 'package:flutter_task/app/views/widgets/link_tab_widget.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
        init: MainController(),
        builder: (controller) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text('Link Manager'),
              bottom: TabBar(
                controller: controller.tabController,
                tabs: const [
                  Tab(text: 'Empty Tab'),
                  Tab(text: 'Links Tab'),
                ],
              ),
            ),
            body: TabBarView(
              controller: controller.tabController,
              children: [
                const Center(
                  child: Text('Empty Tab Content'),
                ),
                if (controller.links.value.isEmpty)
                  const Center(
                    child: Text('No Link Found'),
                  )
                else
                  const LinkTabWidgets()
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                controller.onPressedFloating();
              },
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}
