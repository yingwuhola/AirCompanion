import 'package:get/get.dart';

import 'constants/page.dart';
import 'page/aqi_detail_page/aqi_detail_page.dart';
import 'page/city_page/city_page.dart';
import 'page/forecast_page/forecast_page.dart';
import 'page/home_page/home_page.dart';
import 'page/init_page/init_page.dart';


class Routes {
  static final List<GetPage> getPages = [
    GetPage(name: Pages.init, page: () => InitPage()),
    GetPage(name: Pages.home, page: () => HomePage(), transition: Transition.fadeIn),
    GetPage(name: Pages.city, page: () => CityPage()),
    GetPage(name: Pages.aqiDetail, page: () => AqiDetailPage()),
    GetPage(name: Pages.forecast, page: () => ForecastPage()),
  ];
}
