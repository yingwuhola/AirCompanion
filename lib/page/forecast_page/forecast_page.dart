import 'package:aircompanion/page/forecast_page/forecast_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ForecastPage extends StatelessWidget {
  ForecastPage({super.key});
  final ForecastController controller = Get.put(ForecastController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Air Quality Prediction",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(68, 138, 255, 1),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: GetBuilder<ForecastController>(
        builder: (_) {
          if (controller.forecastList.isEmpty) {
            return Center(
              child: Text(
                "No forecast data available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildChartCard(
                  "AQI Over Time",
                  SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <LineSeries<AqiData, String>>[
                      LineSeries(
                        dataSource: controller.forecastList
                            .take(20)
                            .map(
                              (v) => AqiData(
                                DateFormat('MM-dd HH:mm')
                                    .format(DateTime.fromMillisecondsSinceEpoch(v["dt"] * 1000)),
                                v["aqi"],
                              ),
                            )
                            .toList(),
                        xValueMapper: (AqiData sales, _) => sales.x,
                        yValueMapper: (AqiData sales, _) => sales.y,
                        name: "AQI",
                        color: Colors.green,
                        markerSettings: MarkerSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                buildComponentChart(controller.forecastList, "CO", "co", color: Colors.redAccent),
                buildComponentChart(controller.forecastList, "NO", "no", color: Colors.orange),
                buildComponentChart(controller.forecastList, "NO₂", "no2", color: Colors.pinkAccent),
                buildComponentChart(controller.forecastList, "O₃", "o3", color: Colors.blue),
                buildComponentChart(controller.forecastList, "SO₂", "so2", color: Colors.deepPurple),
                buildComponentChart(controller.forecastList, "PM2.5", "pm2_5", color: Colors.teal),
                buildComponentChart(controller.forecastList, "PM10", "pm10", color: Colors.brown),
                buildComponentChart(controller.forecastList, "NH₃", "nh3", color: Colors.indigo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget buildComponentChart(List list, String text, String key, {Color color = Colors.green}) {
    return buildChartCard(
      "$text Over Time",
      SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <LineSeries<ComponentData, String>>[
          LineSeries(
            dataSource: list
                .take(20)
                .map(
                  (v) => ComponentData(
                    DateFormat('MM-dd HH:mm')
                        .format(DateTime.fromMillisecondsSinceEpoch(v["dt"] * 1000)),
                    v["components"][key] * 1.0,
                  ),
                )
                .toList(),
            xValueMapper: (ComponentData sales, _) => sales.x,
            yValueMapper: (ComponentData sales, _) => sales.y,
            name: text,
            color: color,
            markerSettings: MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class AqiData {
  AqiData(this.x, this.y);
  final String x;
  final int y;
}

class ComponentData {
  ComponentData(this.x, this.y);
  final String x;
  final double y;
}