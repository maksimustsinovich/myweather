import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/models/hourly_weather_model.dart';
import 'package:myweather/widgets/pressure_chart.dart';
import 'package:myweather/widgets/wind_chart.dart';
import '../services/weather_service.dart';
import '../widgets/hourly_weather_tile.dart';
import '../widgets/hourly_weather_chart.dart';
import '../widgets/forecast_day_selector.dart';

class HourlyForecastScreen extends StatefulWidget {
  final String city;

  const HourlyForecastScreen({super.key, required this.city});

  @override
  State<HourlyForecastScreen> createState() => _HourlyForecastScreenState();
}

class _HourlyForecastScreenState extends State<HourlyForecastScreen> {
  List<HourlyWeather> fullData = [];
  List<HourlyWeather> filtered = [];
  List<String> dates = [];
  String selectedDate = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadForecast();
  }

  Future<void> loadForecast() async {
    try {
      final service = WeatherService();
      final result = await service.fetchHourlyForecast(widget.city);

      final allDates = result
          .map((e) => DateFormat('yyyy-MM-dd').format(e.time))
          .toSet()
          .toList();

      setState(() {
        fullData = result;
        dates = allDates;
        selectedDate = allDates.first;
        filtered = _filterByDate(selectedDate);
        loading = false;
      });
    } catch (e) {
      print('Ошибка загрузки прогноза: $e');
    }
  }

  List<HourlyWeather> _filterByDate(String date) {
    return fullData
        .where((e) => DateFormat('yyyy-MM-dd').format(e.time) == date)
        .toList();
  }

  double _maxTemp() =>
      filtered.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);

  double _minTemp() =>
      filtered.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);

  @override
  Widget build(BuildContext context) {
    final weatherId = filtered.isNotEmpty ? filtered[0].weatherCode : 800;

    return Scaffold(
      appBar: AppBar(
        title: Text('Прогноз — ${widget.city}'),
        backgroundColor: Colors.blue,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: WeatherBackgroundHelper.getBackgroundImage(weatherId),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ForecastDaySelector(
                      dates: dates,
                      selectedDate: selectedDate,
                      onSelect: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                          filtered = _filterByDate(newDate);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) =>
                            HourlyWeatherTile(data: filtered[i]),
                      ),
                    ),
                    HourlyWeatherChart(data: filtered),
                    PressureChart(data: filtered),
                    WindChart(data: filtered),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSummaryCard(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Сегодня: ${filtered[0].description[0].toUpperCase()}${filtered[0].description.substring(1)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Макс: ${_maxTemp().round()}°C, Мин: ${_minTemp().round()}°C',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
