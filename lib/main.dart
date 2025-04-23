import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const AirCompanionApp());

/// Root widget
class AirCompanionApp extends StatelessWidget {
  const AirCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirCompanion',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const SplashPage(),
    );
  }
}

//–––––––– Splash ––––––––//
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Shell()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AirCompanion', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

//–––––––– Main shell with bottom‑nav ––––––––//
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _current = 0;
  static const _titles = ['Dashboard', 'Map', 'Details'];
  final _pages = const [DashboardPage(), MapPage(), DetailsPage()];

  void _goHome() => setState(() => _current = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _current == 0
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goHome),
        title: Text(_titles[_current]),
      ),
      body: IndexedStack(index: _current, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current,
        onTap: (i) => setState(() => _current = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart), label: 'Details'),
        ],
      ),
    );
  }
}

//–––––––– Page 1 Dashboard ––––––––//
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<OutdoorData> _future;
  DateTime? _lastFetch;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    setState(() {
      _future = AirQualityApi.fetchOutdoor();
      _lastFetch = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _fetch(),
      child: FutureBuilder<OutdoorData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGauge(d.aqi, d.grade),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _pollutantCircle('PM₂.₅', d.pm25, 'µg/m³'),
                  _pollutantCircle('PM₁₀', d.pm10, 'µg/m³'),
                  _pollutantCircle('O₃', d.o3, 'µg/m³'),
                  _pollutantCircle('CO', d.co, 'µg/m³'),
                ],
              ),
              const SizedBox(height: 24),
              if (_lastFetch != null)
                Text('Last updated: ${DateFormat('yyyy-MM-dd HH:mm').format(_lastFetch!)}', textAlign: TextAlign.center),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGauge(int aqi, String grade) {
    return SfRadialGauge(axes: <RadialAxis>[RadialAxis(minimum: 0, maximum: 500, ranges: <GaugeRange>[
      GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
      GaugeRange(startValue: 50, endValue: 100, color: Colors.yellow),
      GaugeRange(startValue: 100, endValue: 150, color: Colors.orange),
      GaugeRange(startValue: 150, endValue: 200, color: Colors.red),
      GaugeRange(startValue: 200, endValue: 300, color: Colors.purple),
      GaugeRange(startValue: 300, endValue: 500, color: Colors.brown)
    ], pointers: <GaugePointer>[
      NeedlePointer(value: aqi.toDouble())
    ], annotations: <GaugeAnnotation>[
      GaugeAnnotation(angle: 90, positionFactor: 0.1, widget: Column(children: [
        Text('$aqi', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text(grade, style: const TextStyle(fontSize: 16)),
      ]))
    ])]);
  }

  Widget _pollutantCircle(String label, double value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade50),
          child: Center(
            child: Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
        Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

//–––––––– Page 2 Map ––––––––//
class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Map placeholder – integrate google_maps_flutter or flutter_map here'),
    );
  }
}

//–––––––– Page 3 Details (24‑h trend) ––––––––//
class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  List<FlSpot> _mock(List<double> values) => List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
  @override
  Widget build(BuildContext context) {
    // Mock data for 24h, replace with real API / DB.
    final pm25 = List.generate(24, (h) => 10 + h.toDouble());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 3, getTitlesWidget: (v, _) => Text('${v.toInt()}h')))),
          lineTouchData: LineTouchData(enabled: true),
          gridData: FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(spots: _mock(pm25), isCurved: true, barWidth: 2),
          ],
        ),
      ),
    );
  }
}

//–––––––– Models & API ––––––––//
class OutdoorData {
  final int aqi;
  final double pm25;
  final double pm10;
  final double o3;
  final double co;
  OutdoorData({required this.aqi, required this.pm25, required this.pm10, required this.o3, required this.co});
  String get grade {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (Sensitive)';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}

class AirQualityApi {
  static const _url = 'https://api.openweathermap.org/data/2.5/air_pollution';
  static const _lat = 51.5072;
  static const _lon = -0.1276;
  static const _key = 'mykey'; // inject via dotenv / --dart-define

  static Future<OutdoorData> fetchOutdoor() async {
    final uri = Uri.parse('$_url?lat=$_lat&lon=$_lon&appid=$_key');
    final res = await http.get(uri).timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) throw Exception('OWM ${res.statusCode}');
    final obj = json.decode(res.body) as Map<String, dynamic>;
    final first = (obj['list'] as List)[0];
    final main = first['main'] as Map<String, dynamic>;
    final comp = first['components'] as Map<String, dynamic>;
    return OutdoorData(
      aqi: main['aqi'],
      pm25: (comp['pm2_5'] as num).toDouble(),
      pm10: (comp['pm10'] as num).toDouble(),
      o3: (comp['o3'] as num).toDouble(),
      co: (comp['co'] as num).toDouble(),
    );
  }
}
