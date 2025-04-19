import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/helpers/weather_icon_helper.dart';
import 'package:myweather/screens/weather_screen/weather_screen.dart';

import 'package:myweather/services/city_storage_service.dart';
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

  Future<void> _loadCityAndFetchWeather() async {
    final storedCity = await CityStorageService().getLastCity();
    if (storedCity != null) {
      setState(() {
        city = storedCity;
      });
    }
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=ru';

    try {
      final response = await http.get(Uri.parse(url));
      if (kDebugMode) {
        print('📡 GET: $url');
        print('🔢 Response: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Ошибка загрузки данных');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception: $e');
      }
    }
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      weatherData = null;
    });
    await fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    final weatherId = weatherData?['weather'][0]['id'] ?? 0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshWeatherData,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: WeatherBackgroundHelper.getBackgroundImage(weatherId),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  weatherData == null
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          _buildHeaderTile(),
                          Expanded(
                            flex: 1,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                    childAspectRatio: 1.0,
                                  ),
                              itemCount: widget.parameters.length,
                              itemBuilder: (context, index) {
                                return _buildCustomWeatherTile(index);
                              },
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomPanel(),
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

    return Card(
      elevation: 4.0,
      color: Colors.white.withValues(alpha: 0.7),
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
