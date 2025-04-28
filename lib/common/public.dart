import 'package:aircompanion/models/pollution_level.dart';
import 'package:flutter/material.dart';

class Public {
  static Color determinePollutionLevel(double value, List<PollutionLevel>? levels) {
    if (levels == null) return Colors.green;
    for (final level in levels) {
      final meetsMin = value >= level.min; // 大于等于最小值
      final meetsMax = level.max == null ? true : value < level.max!; // 小于最大值
      // 同时满足条件，确定在此范围内
      if (meetsMin && meetsMax) {
        return level.color;
      }
    }
    return Colors.green;
  }
}
