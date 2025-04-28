import 'package:flutter/material.dart';

class PollutionLevel {
  final Color color;
  final double min;
  final double? max;

  const PollutionLevel({required this.color, required this.min, this.max});
}
