import 'package:aircompanion/constants/page.dart';
import 'package:get/get.dart';

class InitController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 1)).then((_) {
      Get.offAllNamed(Pages.home);
    });
  }
}
