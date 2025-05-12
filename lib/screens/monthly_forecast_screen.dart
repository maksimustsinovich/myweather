// lib/screens/monthly_forecast_screen.dart

import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/models/daily_weather_model.dart';
import 'package:myweather/services/weatherapi_service.dart';
import 'package:myweather/theme/app_styles.dart'; // 👈 импортируем стили

class MonthlyForecastScreen extends StatefulWidget {
  final String city;
  final int initialWeatherId;

  const MonthlyForecastScreen({
    Key? key,
    required this.city,
    required this.initialWeatherId,
  }) : super(key: key);

  @override
  _MonthlyForecastScreenState createState() => _MonthlyForecastScreenState();
}

class _MonthlyForecastScreenState extends State<MonthlyForecastScreen> {
  final _svc = WeatherApiService();
  List<DailyWeather> _data = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _data = await _svc.fetchFortnightForecast(widget.city);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Маппинг WMO → WeatherIcons
  IconData _wmoToIcon(int code) {
    switch (code) {
      case 0:
        return WeatherIcons.day_sunny;
      case 1:
        return WeatherIcons.day_sunny_overcast;
      case 2:
        return WeatherIcons.day_cloudy;
      case 3:
        return WeatherIcons.cloud;
      case 45:
      case 48:
        return WeatherIcons.fog;
      case 51:
      case 53:
      case 55:
        return WeatherIcons.sprinkle;
      case 61:
      case 63:
      case 65:
        return WeatherIcons.rain;
      case 71:
      case 73:
      case 75:
        return WeatherIcons.snow;
      case 80:
      case 81:
      case 82:
        return WeatherIcons.showers;
      case 95:
      case 96:
      case 99:
        return WeatherIcons.thunderstorm;
      default:
        return WeatherIcons.na;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.blueAccent),
        title: Text('Прогноз на 2 недели', style: AppStyles.headerCity),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.blue),
        child: SafeArea(
          child:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _buildError()
                  : _data.isEmpty
                  ? Center(
                    child: Text(
                      'Нет данных за этот период',
                      style: AppStyles.dateText.copyWith(color: Colors.white),
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24, top: 8),
                      itemCount: _data.length,
                      itemBuilder: (_, i) => _buildDayCard(_data[i]),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ошибка загрузки',
          style: AppStyles.headerCity.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(_error!, style: AppStyles.dateText.copyWith(color: Colors.white)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _reload, child: const Text('Повторить')),
      ],
    ),
  );

  Widget _buildDayCard(DailyWeather day) {
    final icon = _wmoToIcon(day.weatherCode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4.0,
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📅 Дата — используем titleLarge (AppStyles.headerCity)
              Text(
                day.formattedDate,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 4),

              // 🌡 Температурный диапазон — bodySmall (AppStyles.dateText)
              Text(
                'Мин ${day.minTemp.round()}° — Макс ${day.maxTemp.round()}°',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),

              // 🌡 Текущая температура и иконка
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${day.dayTemp.round()}°C',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 12),
                  BoxedIcon(icon, size: 48, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 4),

              // 🧾 Описание погоды — bodyMedium (AppStyles.tileLabel)
              Text(
                '${day.description[0].toUpperCase()}${day.description.substring(1)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
