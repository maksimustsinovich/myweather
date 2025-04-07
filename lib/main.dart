import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myweather/screens/weather_screen/weather_screen.dart';

void main() {
  initializeDateFormatting().then((_) {
    runApp(const WeatherApp());
  });
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherScreen(),
    );
  }
}
