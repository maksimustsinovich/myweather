// lib/screens/monthly_forecast_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/models/daily_weather_model.dart';
import 'package:myweather/services/weatherapi_service.dart';

class MonthlyForecastScreen extends StatefulWidget {
  final String city;
  final int initialWeatherId;             // <-- добавили сюда

  const MonthlyForecastScreen({
    super.key,
    required this.city,
    required this.initialWeatherId,       // <-- требуем его
  });

  @override
  State<MonthlyForecastScreen> createState() => _MonthlyForecastScreenState();
}

class _MonthlyForecastScreenState extends State<MonthlyForecastScreen> {
  final WeatherApiService _service = WeatherApiService();
  List<DailyWeather> fullData = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      fullData = await _service.fetchFortnightForecast(widget.city);
    } catch (e) {
      debugPrint('Ошибка загрузки 2‑недельного прогноза: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // используем прокинутый weatherId
    final weatherId = widget.initialWeatherId;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Прогноз на 2 недели — ${widget.city}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : fullData.isEmpty
              ? const Center(child: Text('Нет данных за этот период'))
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: WeatherBackgroundHelper.getBackgroundImage(weatherId),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: fullData.length,
                      itemBuilder: (ctx, i) {
                        final day = fullData[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal:16,vertical:8),
                          child: Card(
                            color: Colors.white.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('d MMMM, EEEE','ru').format(day.date),
                                    style: const TextStyle(fontSize:16,fontWeight:FontWeight.bold),
                                  ),
                                  const SizedBox(height:4),
                                  Text(
                                    'Мин ${day.minTemp.round()}° — Макс ${day.maxTemp.round()}°',
                                    style: const TextStyle(fontSize:14),
                                  ),
                                  const SizedBox(height:12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${day.dayTemp.round()}°C',
                                        style: const TextStyle(fontSize:32,fontWeight:FontWeight.bold)),
                                      const SizedBox(width:12),
                                      Image.network(day.iconUrl,width:48,height:48),
                                    ],
                                  ),
                                  const SizedBox(height:4),
                                  Text(
                                    '${day.description[0].toUpperCase()}${day.description.substring(1)}',
                                    style: const TextStyle(fontSize:16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
