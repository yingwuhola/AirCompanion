import 'package:get/get.dart';

class AqiDetailController extends GetxController {
  String city = "";
  int aqi = 1;
  Map aqiData = {};
  // 建议
  Map suggest = {
    1: "Air is clean and healthy. Enjoy any outdoor activity freely.",
    2: "Air is okay for most people. Extra-sensitive individuals may ease off heavy outdoor exercise.",
    3: "Sensitive groups (children, elderly, heart / lung patients) should limit long or intense outdoor activity and may wear a mask. Others can proceed as normal.",
    4: "Everyone may feel effects; sensitive groups could feel them strongly. Reduce heavy outdoor exertion; vulnerable people should stay indoors with an air-purifier.",
    5: "Health alert. Avoid outdoor activity; stay indoors with high-efficiency air-purification. Wear an N95/KN95 mask if you must go outside and seek medical help if breathing issues arise.",
  };

  @override
  void onInit() {
    super.onInit();
    city = Get.arguments["city"];
    aqi = Get.arguments["aqi"];
    aqiData = Get.arguments["components"];
  }
}
