import 'package:aircompanion/common/utils/http.dart';
import 'package:aircompanion/constants/api.dart';
import 'package:get/get.dart';

class ForecastController extends GetxController {
  String city = "";
  double lat = 0;
  double lon = 0;
  List forecastList = [];

  @override
  void onInit() {
    super.onInit();
    city = Get.arguments["city"];
    lat = Get.arguments["lat"] as double;
    lon = Get.arguments["lon"] as double;
    getForecastData(lat, lon);
  }

  // 未来趋势数据
  void getForecastData(double lat, double lon) {
    Http().get(Api.getAqiForecast, {"lat": lat, "lon": lon}).then((data) {
      for (var v in data["list"]) {
        forecastList.add({"aqi": v["main"]["aqi"], "dt": v["dt"], "components": v["components"]});
      }
      update();
    });
  }
}
