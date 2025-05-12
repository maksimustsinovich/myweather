import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/helpers/weather_icon_helper.dart';
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
  final Color accentColor = Colors.blueAccent;

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
    if (storedCity != null) setState(() => city = storedCity);
    await fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=ru';
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
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CityPickerScreen()),
    );
    if (selected != null && selected.isNotEmpty && selected != city) {
      setState(() {
        city = selected;
        weatherData = null;
      });
      await CityStorageService().saveCity(city);
      await fetchWeatherData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherId = weatherData?['weather'][0]['id'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(city),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Статистика шагов',
            onPressed: weatherData == null
                ? null
                : () {
                    final mainWeather = weatherData!['weather'][0]['main'] as String;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatsScreen(currentWeather: mainWeather),
                      ),
                    );
                  },
          ),
          IconButton(
            icon: const Icon(Icons.location_city),
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
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: weatherData == null
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderTile(),
                        const SizedBox(height: 16),
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
                          itemBuilder: (context, index) =>
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

    switch (parameter) {
      case 'temperature':
        return _buildTile(
          label: 'Температура',
          value: '${weatherData?['main']['temp']}°C',
          widget: _buildTemperatureGauge(weatherData?['main']['temp'] ?? 0),
        );
      case 'feels_like':
        return _buildTile(
          label: 'Ощущается',
          value: '${weatherData?['main']['feels_like']}°C',
          widget: _buildTemperatureGauge(
            weatherData?['main']['feels_like'] ?? 0,
          ),
        );
      case 'wind':
        return _buildWindTile();
      case 'humidity':
        return _buildTile(
          label: 'Влажность',
          value: '${weatherData?['main']['humidity']}%',
          widget: _buildHumidityGauge(
            weatherData?['main']['humidity'] + 0.0 ?? 0.0,
          ),
        );
      case 'pressure':
        return _buildTile(
          label: 'Давление',
          value: '${weatherData?['main']['pressure']}',
          widget: _buildPressureGauge(
            weatherData?['main']['pressure'] + 0.0 ?? 760.0,
          ),
        );
      default:
        return _buildTile(label: 'Неизвестный параметр', value: 'N/A');
    }
  }

  Widget _buildTemperatureGauge(double temperature) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: -20,
            maximum: 40,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(value: temperature, width: 10, color: accentColor),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thermostat, color: accentColor, size: 36),
                  ],
                ),
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityGauge(double humidity) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(value: humidity, width: 10, color: accentColor),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, color: accentColor, size: 36),
                  ],
                ),
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPressureGauge(double pressure) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 700,
            maximum: 1200,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(value: pressure, width: 10, color: accentColor),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.speed, color: accentColor, size: 36)],
                ),
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWindTile() {
    final windSpeed = weatherData?['wind']['speed'] ?? 'N/A';
    final windDirectionDegrees = weatherData?['wind']['deg'] ?? 0;
    final windDirectionText = _getWindDirectionText(windDirectionDegrees);

    return Card(
      elevation: 4.0,
      color: Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ветер',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                ),
                const SizedBox(height: 8),
                Text(
                  '$windDirectionText ($windDirectionDegrees°)',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$windSpeed м/с',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: _buildCompass(windDirectionDegrees),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String label,
    required String value,
    Widget? widget,
  }) {
    return Card(
      elevation: 4.0,
      color: Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (widget != null)
            Positioned(bottom: 8.0, right: 8.0, child: widget),
        ],
      ),
    );
  }

  bool _isDayTime(String iconCode) {
    return iconCode.endsWith('d');
  }

Widget _buildHeaderTile() {
  final cityName = weatherData?['name'] ?? 'Город';
  final date = _getFormattedDate(weatherData?['dt']);
  final weatherDescription =
      weatherData?['weather'][0]['description'] ?? 'Неизвестно';
  final iconCode = weatherData?['weather'][0]['icon'] ?? '';
  final isDayTime = _isDayTime(iconCode);
  final weatherIcon = WeatherIconHelper.getWeatherIcon(
    weatherData?['weather'][0]['id'],
    isDayTime,
  );

  return GestureDetector(  // Оборачиваем карточку в GestureDetector
    onTap: () {
      // Переход на экран с детальной погодой для выбранного города
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HourlyForecastScreen(city: cityName),
        ),
      );
    },
    child: Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(weatherIcon, size: 64, color: accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cityName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    weatherDescription[0].toUpperCase() +
                        weatherDescription.substring(1),
                    style: TextStyle(fontSize: 16, color: Colors.grey[1000]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  String _getFormattedDate(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final formatter = DateFormat('d MMMM y, EEEE', 'ru');
    return formatter.format(dateTime);
  }

  Widget _buildCompass(int degrees) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: 0,
            endAngle: 360,
            radiusFactor: 0.9,
            minimum: 0,
            maximum: 360,
            axisLineStyle: AxisLineStyle(
              thicknessUnit: GaugeSizeUnit.logicalPixel,
              thickness: 5,
              color: accentColor,
            ),
            onLabelCreated: labelCreated,
            interval: 45,
            canRotateLabels: true,
            axisLabelStyle: GaugeTextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            labelOffset: 0,
            minorTicksPerInterval: 0,
            majorTickStyle: MajorTickStyle(
              thickness: 1.5,
              lengthUnit: GaugeSizeUnit.factor,
              length: 0.07,
            ),
            showLabels: true,
            pointers: <GaugePointer>[
              NeedlePointer(
                value: degrees.toDouble(),
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFFFF6B78),
                    Color(0xFFFF6B78),
                    Color(0xFFE20A22),
                    Color(0xFFE20A22),
                  ],
                  stops: <double>[0, 0.5, 0.5, 1],
                ),
                needleEndWidth: 4,
                needleStartWidth: 1,
                needleLength: 0.6,
                knobStyle: KnobStyle(
                  knobRadius: 0.08,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.black,
                ),
              ),
              NeedlePointer(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFFE3DFDF),
                    Color(0xFFE3DFDF),
                    Color(0xFF7A7A7A),
                    Color(0xFF7A7A7A),
                  ],
                  stops: <double>[0, 0.5, 0.5, 1],
                ),
                value: (degrees + 180) % 360,
                needleEndWidth: 4,
                needleStartWidth: 1,
                needleLength: 0.6,
                knobStyle: KnobStyle(
                  knobRadius: 0.08,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void labelCreated(AxisLabelCreatedArgs args) {
    if (args.text == '360' || args.text == '0') {
      args.text = 'С';
    } else if (args.text == '45') {
      args.text = 'С-В';
    } else if (args.text == '90') {
      args.text = 'В';
    } else if (args.text == '135') {
      args.text = 'Ю-В';
    } else if (args.text == '180') {
      args.text = 'Ю';
    } else if (args.text == '225') {
      args.text = 'Ю-З';
    } else if (args.text == '270') {
      args.text = 'З';
    } else if (args.text == '315') {
      args.text = 'С-З';
    }
  }

  String _getWindDirectionText(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'С';
    if (degrees >= 22.5 && degrees < 67.5) return 'С-В';
    if (degrees >= 67.5 && degrees < 112.5) return 'В';
    if (degrees >= 112.5 && degrees < 157.5) return 'Ю-В';
    if (degrees >= 157.5 && degrees < 202.5) return 'Ю';
    if (degrees >= 202.5 && degrees < 247.5) return 'Ю-З';
    if (degrees >= 247.5 && degrees < 292.5) return 'З';
    if (degrees >= 292.5 && degrees < 337.5) return 'С-З';
    return 'Неизвестно';
  }
}
