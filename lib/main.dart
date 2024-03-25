import 'package:flutter/material.dart';
import 'package:flutter_task/app/controllers/main_controllers.dart';
import 'package:flutter_task/app/routes/routes.dart';
import 'package:flutter_task/app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'app/adapter/link_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(LinkAdapter());

  Get.put(MainController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Link Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      getPages: AppRoutes.routes,
      initialRoute: mainScreen,
    );
  }
}
