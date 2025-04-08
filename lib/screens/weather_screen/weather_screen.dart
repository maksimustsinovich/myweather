import 'package:flutter/material.dart';
import 'package:myweather/screens/weather_screen/weather_screen_state.dart';

class WeatherScreen extends StatefulWidget {
  final List<String> parameters;
  const WeatherScreen({super.key, required this.parameters});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}
