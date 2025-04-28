import 'dart:math';

import 'package:aircompanion/common/public.dart';
import 'package:aircompanion/common/widget/confirm_dialog.dart';
import 'package:aircompanion/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'AirCompanion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Obx(() => IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                    key: ValueKey<bool>(controller.isDarkMode.value),
                  ),
                ),
                onPressed: controller.toggleTheme,
                tooltip: 'Toggle theme',
              )),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: controller.goToCityPage,
            tooltip: 'Add city',
          ),
        ],
      ),
      body: GetBuilder<HomeController>(
        builder: (_) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: controller.aqiData.isEmpty
                ? _buildEmptyState(context)
                : _buildCityList(context),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_state.png',
            width: 150,
            height: 150,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.cloud_outlined,
              size: 120,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No cities monitored yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add a city to start monitoring air quality',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: controller.goToCityPage,
            icon: const Icon(Icons.add),
            label: const Text('Add City'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.aqiData.length,
      itemBuilder: (context, index) {
        final item = controller.aqiData[index];
        return _buildCityCard(context, item);
      },
    );
  }

  Widget _buildCityCard(BuildContext context, Map item) {
    return Obx(
      () => Hero(
        tag: 'city_${item["city"]}',
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shadowColor: controller.isDarkMode.value
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Constants.aqiColor[item["aqi"]]?.withOpacity(0.5) ?? 
                     Colors.grey.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => controller.goToAqiDetailPage(item),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildAqiIndicator(item),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item["city"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: controller.isDarkMode.value
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _buildForecastButton(item),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Air Quality: ${Constants.aqiLevel[item["aqi"]]}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Constants.aqiColor[item["aqi"]] ?? Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildAqiComponentsGrid(item),
                    ],
                  ),
                ),
                // 添加右下角的删除按钮
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _buildDeleteButton(item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(Map item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDeleteDialog(item),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.delete_outline,
              size: 22,
              color: Colors.red.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAqiIndicator(Map item) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: controller.isDarkMode.value
            ? Colors.grey.shade800
            : Colors.grey.shade100,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                painter: _RingPainter(
                  aqi: item["aqi"],
                  max: 5,
                  ringWidth: 12,
                  progress: value,
                ),
                size: const Size(90, 90),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AQI',
                style: TextStyle(
                  fontSize: 14,
                  color: controller.isDarkMode.value
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item["aqi"].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Constants.aqiColor[item["aqi"]] ?? Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastButton(Map item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => controller.goToForecastPage(
          item["city"],
          item["lat"],
          item["lon"],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bar_chart,
                size: 18,
              ),
              const SizedBox(width: 4),
              const Text(
                'Forecast',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAqiComponentsGrid(Map item) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _buildComponentItem("co", "CO", item["components"]),
        _buildComponentItem("no", "NO", item["components"]),
        _buildComponentItem("no2", "NO₂", item["components"]),
        _buildComponentItem("o3", "O₃", item["components"]),
        _buildComponentItem("so2", "SO₂", item["components"]),
        _buildComponentItem("pm2_5", "PM2.5", item["components"]),
        _buildComponentItem("pm10", "PM10", item["components"]),
        _buildComponentItem("nh3", "NH₃", item["components"]),
      ],
    );
  }

  Widget _buildComponentItem(String key, String text, Map map) {
    final color = Public.determinePollutionLevel(
      map[key] * 1.0,
      Constants.pollutionLevels[key],
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            map[key].toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: controller.isDarkMode.value
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map item) {
    Get.dialog(
      ConfirmDialog(
        title: 'Remove City',
        content: "Are you sure you want to remove ${item["city"]} from your monitored cities?",
        confirm: () {
          controller.deleteCity(item);
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int aqi;
  final int max;
  final double ringWidth;
  final double progress;

  _RingPainter({
    required this.aqi,
    required this.max,
    required this.ringWidth,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - ringWidth / 2;
    final double progressValue = aqi / max * progress;

    // 绘制背景环
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制进度环
    final progressPaint = Paint()
      ..color = Constants.aqiColor[aqi] ?? Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progressValue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.aqi != aqi ||
      oldDelegate.max != max ||
      oldDelegate.progress != progress;
}