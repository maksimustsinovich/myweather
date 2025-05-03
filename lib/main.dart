import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';        // ← for kIsWeb
import 'package:intl/date_symbol_data_local.dart';

import 'package:myweather/services/step_background_service.dart';
import 'package:myweather/screens/weather_screen/weather_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  if (!kIsWeb) {
    // only on mobile platforms—and swallow any errors
    try {
      initializeBackgroundService();
    } catch (e, st) {
      debugPrint('⚠️ bg‐service init failed: $e\n$st');
    }
  }

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final customParameters = [
      'temperature',
      'feels_like',
      'humidity',
      'pressure',
      'wind',
    ];

    return MaterialApp(
      title: 'Погода',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(parameters: customParameters),
    );
  }
}
