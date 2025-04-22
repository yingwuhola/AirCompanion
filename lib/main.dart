import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const AirCompanionApp());

class AirCompanionApp extends StatelessWidget {
  const AirCompanionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirCompanion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

/// Splash screen that displays the app name on a white background for 1 s,
/// then navigates to [HomePage].
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'AirCompanion',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Home page: shows indoor and outdoor air‑quality metrics side by side.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<AirQualityData> _indoorFuture;
  late Future<AirQualityData> _outdoorFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _indoorFuture = AirQualityService.fetchIndoor();
      _outdoorFuture = AirQualityService.fetchOutdoor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildCard('Indoor', _indoorFuture)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCard('Outdoor', _outdoorFuture)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Future<AirQualityData> future) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<AirQualityData>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final data = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('AQI: ${data.aqi}', style: const TextStyle(fontSize: 18)),
                Text('CO₂: ${data.co2} ppm'),
                Text('TVOC: ${data.tvoc} ppb'),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Simple model for air‑quality data.
class AirQualityData {
  final int aqi;
  final int co2;
  final int tvoc;

  AirQualityData({required this.aqi, required this.co2, required this.tvoc});

  factory AirQualityData.fromJson(Map<String, dynamic> json) => AirQualityData(
        aqi: json['aqi'] as int,
        co2: json['co2'] as int,
        tvoc: json['tvoc'] as int,
      );
}

/// Service class – replace the endpoint/API‑key strings with your own values.
class AirQualityService {
  static const String _esp32BaseUrl = 'http://esp32.local';
  static const String _openWeatherUrl =
      'https://api.openweathermap.org/data/2.5/air_pollution';
  static const String _openWeatherApiKey = '<apikey>';
  static const double _lat = 51.5072;
  static const double _lon = -0.1276;

  /// Fetch indoor data from ESP32 (expects JSON {"aqi":…, "co2":…, "tvoc":…}).
  static Future<AirQualityData> fetchIndoor() async {
    final uri = Uri.parse('$_esp32BaseUrl/air');
    final res = await http.get(uri).timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) throw Exception('ESP32 error ${res.statusCode}');
    return AirQualityData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Fetch outdoor data from OpenWeatherMap (maps to nearest station).
  static Future<AirQualityData> fetchOutdoor() async {
    final uri = Uri.parse(
        '$_openWeatherUrl?lat=$_lat&lon=$_lon&appid=$_openWeatherApiKey');
    final res = await http.get(uri).timeout(const Duration(seconds: 5));
    if (res.statusCode != 200) {
      throw Exception('OWM error ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final main = (decoded['list'] as List).first['main'] as Map<String, dynamic>;
    final components = (decoded['list'] as List).first['components'] as Map<String, dynamic>;
    return AirQualityData(
      aqi: main['aqi'] as int,
      co2: (components['co'] as num).round(),
      tvoc: (components['nh3'] as num).round(),
    );
  }
}
