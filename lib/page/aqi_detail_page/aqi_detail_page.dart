import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aircompanion/common/public.dart';
import 'package:aircompanion/constants/constants.dart';
import 'package:aircompanion/page/aqi_detail_page/aqi_detail_controller.dart';

class AqiDetailPage extends StatefulWidget {
  const AqiDetailPage({super.key});

  @override
  State<AqiDetailPage> createState() => _AqiDetailPageState();
}

class _AqiDetailPageState extends State<AqiDetailPage> with SingleTickerProviderStateMixin {
  final AqiDetailController c = Get.put(AqiDetailController());
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 20, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              c.city,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
            onPressed: () {
              // 刷新数据
              _animationController.reset();
              _animationController.forward();
              c.update();
            },
          ),
        ],
      ),
      body: GetBuilder<AqiDetailController>(
        builder: (_) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- AQI Ring ---
              Center(
                child: Hero(
                  tag: 'aqi_ring_${c.city}',
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 外发光效果
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Constants.aqiColor[c.aqi]?.withOpacity(0.3) ?? 
                                       Colors.green.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // 动画进度环
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _EnhancedRingPainter(
                                aqi: c.aqi,
                                color: Constants.aqiColor[c.aqi] ?? Colors.green,
                                animationValue: _animation.value,
                              ),
                              size: const Size(240, 240),
                            );
                          },
                        ),
                        // 中心内容
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/images/aqi.png', width: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AQI',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '${c.aqi}',
                              style: textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Constants.aqiColor[c.aqi]?.withOpacity(0.2) ?? 
                                       Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                Constants.aqiLevel[c.aqi] ?? '',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Constants.aqiColor[c.aqi] ?? Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              // --- 污染物指标 ---
              _SectionHeader(
                title: 'Pollutants',
                icon: Icons.science_outlined,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2, // 增加高度，修复溢出问题
                children: Constants.pollutionLevels.keys
                    .map((k) => _EnhancedPollutantTile(
                          code: k,
                          controller: c,
                          animation: _animation,
                        ))
                    .toList(),
              ),

              const SizedBox(height: 40),
              
              // --- 健康提示 ---
              _SectionHeader(
                title: 'Health Tips',
                icon: Icons.health_and_safety_outlined,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),
              _HealthTipsCard(
                content: c.suggest[c.aqi] ?? '',
                color: Constants.aqiColor[c.aqi] ?? Colors.green,
                textTheme: textTheme,
              ),
              
              const SizedBox(height: 30),
              
              // --- 附加信息 ---
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Updated at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data from EPA monitoring stations',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- 容器标题 ----------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.colorScheme,
    required this.textTheme,
  });
  
  final String title;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ---------------- 污染物 Tile ----------------
class _EnhancedPollutantTile extends StatelessWidget {
  const _EnhancedPollutantTile({
    required this.code,
    required this.controller,
    required this.animation,
    super.key,
  });
  
  final String code;
  final AqiDetailController controller;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final value = (controller.aqiData[code] as num).toDouble();
    final color = Public.determinePollutionLevel(value, Constants.pollutionLevels[code]);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animatedValue = value * animation.value;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getPollutantName(code),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                animatedValue.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _getPollutantName(String code) {
    switch (code.toLowerCase()) {
      case 'co': return 'Carbon Monoxide';
      case 'no': return 'Nitric Oxide';
      case 'no2': return 'Nitrogen Dioxide';
      case 'o3': return 'Ozone';
      case 'so2': return 'Sulfur Dioxide';
      case 'pm2.5': return 'Fine Particles';
      case 'pm10': return 'Coarse Particles';
      case 'nh3': return 'Ammonia';
      default: return '';
    }
  }
}

// ---------------- 健康提示卡片 ----------------
class _HealthTipsCard extends StatelessWidget {
  const _HealthTipsCard({
    required this.content,
    required this.color,
    required this.textTheme,
  });
  
  final String content;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: color,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Recommendations',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 增强版圆环 Painter ----------------
class _EnhancedRingPainter extends CustomPainter {
  _EnhancedRingPainter({
    required this.aqi,
    required this.color,
    required this.animationValue,
  });
  
  final int aqi;
  final Color color;
  final double animationValue;
  static const double _w = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - _w / 2;

    // 底环（浅色）
    final bg = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = _w;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0.75 * pi, 1.5 * pi, false, bg);

    // 计算动画的扫描角度
    final fullSweep = 1.5 * pi * (aqi / 500); // 假设AQI最大值为500
    final sweep = fullSweep * animationValue;
    
    // 渐变效果
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      transform: const GradientRotation(0.75 * pi),
      colors: [
        color.withOpacity(0.7),
        color,
        color,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    // 前环（渐变色）
    final fg = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _w
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(rect, 0.75 * pi, sweep, false, fg);
    
    // 添加小点点装饰
    final dotRadius = 3.0;
    final dotPaint = Paint()..color = Colors.white;
    
    // 计算dot位置
    final dotAngle = 0.75 * pi + sweep;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);
    
    // 只在有值时绘制
    if (animationValue > 0) {
      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnhancedRingPainter oldDelegate) {
    return oldDelegate.aqi != aqi || 
           oldDelegate.color != color || 
           oldDelegate.animationValue != animationValue;
  }
}