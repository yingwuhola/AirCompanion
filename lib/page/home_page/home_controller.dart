import 'dart:convert';

import 'package:aircompanion/common/utils/http.dart';
import 'package:aircompanion/common/utils/sp_util.dart';
import 'package:aircompanion/constants/api.dart';
import 'package:aircompanion/constants/constants.dart';
import 'package:aircompanion/constants/page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List airQualityList = [];
  List<Map> aqiData = []; 

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() async {
    String? spCityStr = SpUtil.getString(Constants.spCity);
    if (spCityStr != null) {
      List cityList = json.decode(spCityStr);
      for (var v in cityList) {
        await getAirPollutionData(v["city"], v["lat"], v["lon"]);
      }
    }
  }

  // 获取空气质量数据
  Future getAirPollutionData(String city, double lat, double lon) async {
    await Http().get(Api.getAirQuality, {"lat": lat, "lon": lon}).then((data) {
      aqiData.add({
        "city": city,
        "lat": lat,
        "lon": lon,
        "aqi": data["list"][0]["main"]["aqi"],
        "components": data["list"][0]["components"],
      });
      update();
    });
  }

  // 删除城市
  void deleteCity(Map map) {
    aqiData.remove(map);


    String? spCityStr = SpUtil.getString(Constants.spCity);
    List cityList = json.decode(spCityStr!);
    for (var v in cityList) {
      if (v["city"] == map["city"] && v["lat"] == map["lat"] && v["lon"] == map["lon"]) {
        cityList.remove(v);
        break;
      }
    }
    SpUtil.setString(Constants.spCity, json.encode(cityList));

    update();
  }


  void goToCityPage() {
    Get.toNamed(Pages.city)?.then((value) {
      if (value != null) {
        getAirPollutionData(value["name"], value["lat"], value["lon"]);
        Map map = {"city": value["name"], "lat": value["lat"], "lon": value["lon"]};

        String? spCityStr = SpUtil.getString(Constants.spCity);
        if (spCityStr != null) {
          List cityList = json.decode(spCityStr);
          cityList.add(map);
          SpUtil.setString(Constants.spCity, json.encode(cityList));
        } else {
          List cityList = [map];
          SpUtil.setString(Constants.spCity, json.encode(cityList));
        }
      }
    });
  }


  void goToAqiDetailPage(Map map) {
    Get.toNamed(Pages.aqiDetail, arguments: map);
  }

  void goToForecastPage(String city, double lat, double lon) {
    Get.toNamed(Pages.forecast, arguments: {"city": city, "lat": lat, "lon": lon});
  }

 
  var isDarkMode = false.obs; 


  ThemeData get currentTheme => isDarkMode.value ? _darkTheme : _lightTheme;


  void toggleTheme() => isDarkMode.toggle();

  static final ThemeData _lightTheme = ThemeData.light().copyWith(
    primaryColor: const Color.fromARGB(201, 0, 242, 255),
    appBarTheme: const AppBarTheme(
      color: Color.fromRGBO(234, 56, 145, 0.614),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
  );

  static final ThemeData _darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.indigo,
    // scaffoldBackgroundColor: Colors.grey,
    appBarTheme: const AppBarTheme(
      color: Color.fromRGBO(0, 0, 0, 1),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
  );
}


