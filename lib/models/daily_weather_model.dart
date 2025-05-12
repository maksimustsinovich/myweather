// lib/models/daily_weather_model.dart

import 'package:intl/intl.dart';

class DailyWeather {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double dayTemp;
  final int weatherCode;     // WMO weather code из Open-Meteo
  final String description;  // описание на русском

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.dayTemp,
    required this.weatherCode,
    required this.description,
  });

  String get formattedDate => DateFormat('d MMMM, EEEE', 'ru').format(date);
}
