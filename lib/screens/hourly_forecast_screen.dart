import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/helpers/weather_icon_helper.dart';
import 'package:myweather/models/hourly_weather_model.dart';
import 'package:myweather/services/weather_service.dart';
import 'package:myweather/widgets/forecast_day_selector.dart';
import 'package:myweather/widgets/hourly_weather_tile.dart';
import 'package:myweather/widgets/charts/custom_hourly_weather_chart.dart';
import 'package:myweather/widgets/charts/custom_pressure_chart.dart';
import 'package:myweather/widgets/charts/custom_wind_chart.dart';

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
      final allDates =
          result
              .map((e) => DateFormat('yyyy-MM-dd').format(e.time))
              .toSet()
              .toList()
            ..sort();

      setState(() {
        fullData = result;
        dates = allDates;
        selectedDate = allDates.first;
        filtered = _filterByDate(selectedDate);
        loading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки прогноза: $e');
    }
  }

  List<HourlyWeather> _filterByDate(String date) =>
      fullData
          .where((item) => DateFormat('yyyy-MM-dd').format(item.time) == date)
          .toList();

  double _maxTemp() =>
      filtered.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);

  double _minTemp() =>
      filtered.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);

  bool _isDayTime(String iconCode) => iconCode.endsWith('d');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Получаем текущую тему
    final weatherId = filtered.isNotEmpty ? filtered[0].weatherCode : 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Прогноз', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: WeatherBackgroundHelper.getBackgroundImage(
                  //     weatherId,
                  //   ),
                  //   fit: BoxFit.cover,
                  // ),
                  color: Colors.blueAccent,
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            color: Colors.white.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ForecastDaySelector(
                                dates: dates,
                                selectedDate: selectedDate,
                                onSelect: (newDate) {
                                  setState(() {
                                    selectedDate = newDate;
                                    filtered = _filterByDate(newDate);
                                  });
                                },
                                fullData: fullData,
                                city: widget.city,
                                weatherId: weatherId,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildHeaderCard(theme),
                        const SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _buildHourlyList(),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomHourlyWeatherChart(data: filtered),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomPressureChart(data: filtered),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomWindChart(data: filtered),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(theme),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildHourlyList() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filtered.length,
        itemBuilder: (_, i) => HourlyWeatherTile(data: filtered[i]),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    if (filtered.isEmpty) return const SizedBox.shrink();
    final now = filtered[0];
    final isDay = _isDayTime(now.icon);
    final iconData = WeatherIconHelper.getWeatherIcon(now.weatherCode, isDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('d MMMM, EEEE', 'ru').format(now.time),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${now.temperature.round()}°C',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(iconData, size: 50, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ощущается как ${now.feelsLike.round()}°C',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${now.description[0].toUpperCase()}${now.description.substring(1)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    if (filtered.isEmpty) return const SizedBox.shrink();
    final now = filtered[0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.white.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Подробности',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metricCard('Давление', '${now.pressure} гПа', theme),
                  _metricCard('Ветер', '${now.windSpeed.round()} м/с', theme),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metricCard('Макс.', '${_maxTemp().round()}°', theme),
                  _metricCard('Мин.', '${_minTemp().round()}°', theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
