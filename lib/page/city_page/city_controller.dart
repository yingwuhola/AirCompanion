import 'package:aircompanion/common/utils/http.dart';
import 'package:aircompanion/constants/api.dart';
import 'package:get/get.dart';

class CityController extends GetxController {
  List cityList = [];

  // 获取搜索的城市数据
  void getCityList(String text) {
    Http().get(Api.getGeo, {"q": text, "limit": "5"}).then((data) {
      cityList = data;
      update();
    });
  }
}
