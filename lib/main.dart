import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ← for kIsWeb
import 'package:intl/date_symbol_data_local.dart';

import 'package:myweather/services/step_background_service.dart';
import 'package:myweather/screens/weather_screen/weather_screen.dart';
import 'package:myweather/theme/app_styles.dart'; // 👈 импортируем стили

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  if (!kIsWeb) {
    // only on mobile platforms—and swallow any errors
    try {
      // initializeBackgroundService();
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
      'sun'
    ];

    return MaterialApp(
      title: 'Погода',
      theme: _buildAppTheme(), // 👈 применили кастомную тему
      home: WeatherScreen(parameters: customParameters),
    );
  }

  // 🎨 Метод для построения темы приложения
  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, // цвет иконок и текста в AppBar
      ),
      textTheme: const TextTheme(
        bodyLarge: AppStyles.tileValue,
        bodyMedium: AppStyles.tileLabel,
        titleLarge: AppStyles.headerCity,
        labelLarge: AppStyles.windSpeed,
        labelMedium: AppStyles.windDirection,
        bodySmall: AppStyles.dateText,
      ),
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(secondary: AppStyles.accentColor),
    );
  }
}