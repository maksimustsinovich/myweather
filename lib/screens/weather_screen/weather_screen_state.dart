import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myweather/helpers/tile_helper.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/helpers/weather_icon_helper.dart';
import 'package:myweather/models/city_location.dart';
import 'package:myweather/models/day_stat.dart';
import 'package:myweather/screens/city_picker_screen/city_picker_screen_state.dart';
import 'package:myweather/screens/stats_screen.dart';
import 'package:myweather/screens/hourly_forecast_screen.dart';
import 'package:myweather/screens/weather_screen/weather_screen.dart';
import 'package:myweather/services/city_storage_service.dart';
import 'package:myweather/services/db_helper.dart';
import 'package:myweather/services/weather_service.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '21cc003fb684d8f02f4fefabc56c390f';
  String city = 'Minsk';
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    _loadCityAndFetchWeather();
  }

  Future<void> _saveYesterdayStat() async {
    if (weatherData == null) return;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateKey = DateFormat('yyyy-MM-dd').format(yesterday);
    final stats = await DBHelper.fetchDailyStatsWithWeather();
    final yesterdayStat = stats.firstWhere(
      (s) => s.date == dateKey,
      orElse: () => DayStat(date: dateKey, steps: 0, weather: '', temp: 0.0),
    );
    final stepsYesterday = yesterdayStat.steps;
    final lat = (weatherData!['coord']['lat'] as num).toDouble();
    final lon = (weatherData!['coord']['lon'] as num).toDouble();
    final weatherInfo = await WeatherService().fetchHistoricWeather(
      lat: lat,
      lon: lon,
      date: yesterday,
    );
    final stat = DayStat(
      date: dateKey,
      steps: stepsYesterday,
      weather: weatherInfo.main,
      temp: weatherInfo.temp,
    );
    await DBHelper.upsertStat(stat);
  }

  Future<void> _loadCityAndFetchWeather() async {
    final storedCity = await CityStorageService().getLastCity();
    if (storedCity != null) {
      setState(() {
        city = storedCity.name;
        selectedCity = storedCity;
      });
    }
    await fetchWeatherData();
  }

  CityLocation? selectedCity; // ← храним координаты и имя

  Future<void> fetchWeatherData() async {
    final lat = selectedCity?.lat ?? 53.9; // Минск по умолчанию
    final lon = selectedCity?.lon ?? 27.5667;

    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=ru';

    try {
      final response = await http.get(Uri.parse(url));
      if (kDebugMode) debugPrint('GET $url => ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() => weatherData = data);
        await _saveYesterdayStat();
      } else {
        throw Exception('Ошибка загрузки данных: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception: $e');
    }
  }

  Future<void> _refreshWeatherData() async {
    setState(() => weatherData = null);
    await fetchWeatherData();
  }

  Future<void> _selectCity() async {
    final result = await Navigator.push<CityLocation>(
      context,
      MaterialPageRoute(builder: (_) => const CityPickerScreen()),
    );
    if (result != null) {
      setState(() {
        city = result.name;
        selectedCity = result;
      });
      await CityStorageService().saveCity(result);
      await CityStorageService().saveLastCity(result);
      await fetchWeatherData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weatherId = weatherData?['weather'][0]['id'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          weatherData?['name'] ?? 'Город',
          style: theme.textTheme.titleLarge, // ✅ стиль из AppStyles
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city),
            color: Colors.blueAccent,
            tooltip: 'Выбрать город',
            onPressed: _selectCity,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Фоновое изображение во весь экран
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: WeatherBackgroundHelper.getBackgroundImage(weatherId),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Поверх фона — контент со скроллом и pull-to-refresh
          RefreshIndicator(
            onRefresh: _refreshWeatherData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: 48,
              ),
              child:
                  weatherData == null
                      ? const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TileHelper.buildHeaderTile(weatherData, context),
                          const SizedBox(height: 32),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                            itemCount: widget.parameters.length,
                            itemBuilder:
                                (context, index) =>
                                    _buildCustomWeatherTile(index),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomWeatherTile(int index) {
    final parameter = widget.parameters[index];
    final theme = Theme.of(context);

    switch (parameter) {
      case 'temperature':
        return TileHelper.buildTile(
          label: 'Температура',
          value: '${weatherData?['main']['temp']}°C',
          labelStyle: theme.textTheme.bodyMedium, // ✅ стиль из AppStyles
          valueStyle: theme.textTheme.bodyLarge,
          widget: TileHelper.buildTemperatureGauge(
            weatherData?['main']['temp'] ?? 0,
          ),
        );
      case 'feels_like':
        return TileHelper.buildTile(
          label: 'Ощущается',
          value: '${weatherData?['main']['feels_like']}°C',
          labelStyle: theme.textTheme.bodyMedium,
          valueStyle: theme.textTheme.bodyLarge,
          widget: TileHelper.buildTemperatureGauge(
            weatherData?['main']['feels_like'] ?? 0,
          ),
        );
      case 'wind':
        return TileHelper.buildWindTile(
          weatherData: weatherData,
          labelStyle: theme.textTheme.bodyMedium,
          valueStyle: theme.textTheme.bodyLarge,
          windDirectionStyle: theme.textTheme.labelMedium,
          windSpeedStyle: theme.textTheme.labelLarge,
        );
      case 'humidity':
        return TileHelper.buildTile(
          label: 'Влажность',
          value: '${weatherData?['main']['humidity']}%',
          labelStyle: theme.textTheme.bodyMedium,
          valueStyle: theme.textTheme.bodyLarge,
          widget: TileHelper.buildHumidityGauge(
            weatherData?['main']['humidity'] + 0.0 ?? 0.0,
          ),
        );
      case 'pressure':
        return TileHelper.buildTile(
          label: 'Давление',
          value: '${weatherData?['main']['pressure']}',
          labelStyle: theme.textTheme.bodyMedium,
          valueStyle: theme.textTheme.bodyLarge,
          widget: TileHelper.buildPressureGauge(
            weatherData?['main']['pressure'] + 0.0 ?? 760.0,
          ),
        );
      case 'sun': // Новый кейс для фазы дня
        return TileHelper.buildSunPhasesTile(
          weatherData,
          labelStyle: theme.textTheme.bodyMedium,
          valueStyle: theme.textTheme.bodyLarge,
        );
      default:
        return TileHelper.buildTile(
          label: 'Неизвестный параметр',
          value: 'N/A',
          labelStyle: theme.textTheme.bodyMedium,
          valueStyle: theme.textTheme.bodyLarge,
        );
    }
  }
}
