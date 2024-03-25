import 'package:flutter/material.dart';
import 'package:flutter_task/app/utils/my_utils.dart';
import 'package:flutter_task/app/views/dialogs/delete_link.dart';
import 'package:flutter_task/app/views/dialogs/edit_link.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:hive/hive.dart';

import '../adapter/link_adapter.dart';

class MainController extends GetxController
    with GetSingleTickerProviderStateMixin, MyUtils {
  late TabController tabController;
  TextEditingController urlController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  Rx<List<Link>> links = Rx<List<Link>>([]);

  @override
  void onClose() {
    tabController.dispose();
    urlController.dispose();
    titleController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    loadLinks();
    super.onInit();
  }

  Future<void> loadLinks() async {
    final box = await Hive.openBox<Link>('links');
    // box.clear();
    // setState(() {
    links.value = box.values.toList();
    // });
  }

  void saveLink() async {
    final String url = urlController.text.trim();
    final String title = titleController.text.trim();

    // Check if the number of links is less than 3
    if (links.value.length >= 3) {
      Fluttertoast.showToast(msg: 'You can only add up to 3 links.');

      return;
    }

    // Check if the URL length exceeds 25 characters
    if (url.length > 25) {
      Fluttertoast.showToast(msg: 'URL cannot exceed 25 characters.');

      return;
    }

    if (MyUtils.isValidUrl(url)) {
      final box = await Hive.openBox<Link>('links');
      final link = Link(
          url: url,
          title: title.isNotEmpty ? title : MyUtils.extractDomain(url));
      box.add(link);
      // setState(() {
      links.value.add(link);
      urlController.clear();
      titleController.clear();
      // });
      Get.back();
      update();

      // Navigator.pop(context); // Close the bottom sheet
    } else {
      Fluttertoast.showToast(msg: 'Invalid URL');
    }
  }

  Future<void> deleteLink(int index, Link link) async {
    return showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return DeleteLinkDialog(index: index, link: link);
      },
    );
  }

  void editLink(Link link) {
    urlController.text = link.url;
    titleController.text = link.title;
    showModalBottomSheet(
      isScrollControlled: true,
      context: Get.context!,
      builder: (context) {
        return LinkDialog(
          link: link,
        );
      },
    );
  }

  void showLinkBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: Get.context!,
      builder: (context) {
        return const LinkDialog();
      },
    );
  }

  void updateLink(Link link) async {
    final url = urlController.text.trim();
    final title = titleController.text.trim();

    // Check if the URL length exceeds 25 characters
    if (url.length > 25) {
      Fluttertoast.showToast(msg: 'URL cannot exceed 25 characters.');
      return;
    }

    if (MyUtils.isValidUrl(url)) {
      link.url = url;
      link.title = title.isNotEmpty ? title : MyUtils.extractDomain(url);
      await link.save(); // Save the updated link
      // setState(() {
      urlController.clear();
      titleController.clear();
      // });
      update();
      Get.back(); // Close the bottom sheet
    } else {
      Fluttertoast.showToast(msg: 'Invalid URL');
    }
  }

  void onPressedFloating() {
    urlController.text = '';
    titleController.text = '';
    showLinkBottomSheet();
  }

  Future<void> deleteTask(index, link) async {
    final box = await Hive.openBox<Link>('links');

    await box.deleteAt(index);
    links.value.removeAt(index);

    update();

    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: const Text('Delete Successfully'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            box.add(link);
            // setState(() {
            links.value.add(link);
            urlController.clear();
            titleController.clear();
            update();
          },
        )));
    Navigator.of(Get.context!).pop(true);
  }
}
