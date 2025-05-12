// lib/screens/monthly_forecast_screen.dart

import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/models/daily_weather_model.dart';
import 'package:myweather/services/weatherapi_service.dart';

class MonthlyForecastScreen extends StatefulWidget {
  final String city;
  final int initialWeatherId;

  const MonthlyForecastScreen({
    Key? key,
    required this.city,
    required this.initialWeatherId,
  }) : super(key: key);

  @override
  _MonthlyForecastScreenState createState() =>
      _MonthlyForecastScreenState();
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
    setState(() { _loading = true; _error = null; });
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
      case 0: return WeatherIcons.day_sunny;
      case 1: return WeatherIcons.day_sunny_overcast;
      case 2: return WeatherIcons.day_cloudy;
      case 3: return WeatherIcons.cloud;
      case 45:
      case 48: return WeatherIcons.fog;
      case 51:
      case 53:
      case 55: return WeatherIcons.sprinkle;
      case 61:
      case 63:
      case 65: return WeatherIcons.rain;
      case 71:
      case 73:
      case 75: return WeatherIcons.snow;
      case 80:
      case 81:
      case 82: return WeatherIcons.showers;
      case 95:
      case 96:
      case 99: return WeatherIcons.thunderstorm;
      default: return WeatherIcons.na;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text('Прогноз на 2 недели — ${widget.city}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: WeatherBackgroundHelper
                .getBackgroundImage(widget.initialWeatherId),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : _data.isEmpty
                      ? const Center(
                          child: Text(
                            'Нет данных за этот период',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _reload,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                                bottom: 24, top: 8),
                            itemCount: _data.length,
                            itemBuilder: (_, i) =>
                                _buildDayCard(_data[i]),
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
            const Text('Ошибка загрузки',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.white70)),
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
        color: Colors.white.withOpacity(0.3),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day.formattedDate,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'Мин ${day.minTemp.round()}° — Макс ${day.maxTemp.round()}°',
                style: const TextStyle(
                    fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${day.dayTemp.round()}°C',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  BoxedIcon(icon, size: 48, color: Colors.white),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${day.description[0].toUpperCase()}'
                '${day.description.substring(1)}',
                style:
                    const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
