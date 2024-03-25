import 'package:flutter_task/app/bindings/main_bindings.dart';
import 'package:flutter_task/app/utils/constants.dart';
import 'package:flutter_task/app/views/screens/main_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static final List<GetPage> routes = [
    //splash and onboarding

    GetPage(
        name: mainScreen,
        page: () => const MainScreen(),
        binding: MainBindings()),
  ];
}
