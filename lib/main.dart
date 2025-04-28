import 'package:aircompanion/page/home_page/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common/utils/http.dart';
import 'common/utils/sp_util.dart';
import 'constants/page.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runMainAsync();
}

void runMainAsync() async {
  await SpUtil.getInstance();
  Http.initialize(); 
  final HomeController controller = Get.put(HomeController());
  runApp(
    Obx(
      () => GetMaterialApp(
        title: 'AirCompanion',
        theme: controller.currentTheme,
        defaultTransition: Transition.rightToLeft,
        getPages: Routes.getPages,
        initialRoute: Pages.init,
      ),
    ),
  );
}
