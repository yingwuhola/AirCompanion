import 'package:flutter/material.dart';

import '../models/pollution_level.dart';

class Constants {
  static const spCity = "SpCity";
  // aqi等级描述
  static const Map aqiLevel = {1: "Good", 2: "Fair", 3: "Moderate", 4: "Poor", 5: "Very Poor"};
  // aqi等级颜色
  static const aqiColor = {
    1: Colors.green,
    2: Colors.yellow,
    3: Colors.orange,
    4: Colors.deepOrange,
    5: Colors.red,
  };

  static const pollutionLevels = {
    'so2': [
      PollutionLevel(color: Colors.green, min: 0, max: 20),
      PollutionLevel(color: Colors.yellow, min: 20, max: 80),
      PollutionLevel(color: Colors.orange, min: 80, max: 250),
      PollutionLevel(color: Colors.deepOrange, min: 250, max: 350),
      PollutionLevel(color: Colors.red, min: 350),
    ],
    'no2': [
      PollutionLevel(color: Colors.green, min: 0, max: 40),
      PollutionLevel(color: Colors.yellow, min: 40, max: 70),
      PollutionLevel(color: Colors.orange, min: 70, max: 150),
      PollutionLevel(color: Colors.deepOrange, min: 150, max: 200),
      PollutionLevel(color: Colors.red, min: 200),
    ],
    'pm10': [
      PollutionLevel(color: Colors.green, min: 0, max: 20),
      PollutionLevel(color: Colors.yellow, min: 20, max: 50),
      PollutionLevel(color: Colors.orange, min: 50, max: 100),
      PollutionLevel(color: Colors.deepOrange, min: 100, max: 200),
      PollutionLevel(color: Colors.red, min: 200),
    ],
    'pm2_5': [
      PollutionLevel(color: Colors.green, min: 0, max: 10),
      PollutionLevel(color: Colors.yellow, min: 10, max: 25),
      PollutionLevel(color: Colors.orange, min: 25, max: 50),
      PollutionLevel(color: Colors.deepOrange, min: 50, max: 75),
      PollutionLevel(color: Colors.red, min: 75),
    ],
    'o3': [
      PollutionLevel(color: Colors.green, min: 0, max: 60),
      PollutionLevel(color: Colors.yellow, min: 60, max: 100),
      PollutionLevel(color: Colors.orange, min: 100, max: 140),
      PollutionLevel(color: Colors.deepOrange, min: 140, max: 180),
      PollutionLevel(color: Colors.red, min: 180),
    ],
    'co': [
      PollutionLevel(color: Colors.green, min: 0, max: 4400),
      PollutionLevel(color: Colors.yellow, min: 4400, max: 9400),
      PollutionLevel(color: Colors.orange, min: 9400, max: 12400),
      PollutionLevel(color: Colors.deepOrange, min: 12400, max: 15400),
      PollutionLevel(color: Colors.red, min: 15400),
    ],
  };
}

