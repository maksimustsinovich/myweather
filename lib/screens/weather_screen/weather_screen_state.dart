import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myweather/helpers/weather_background_helper.dart';
import 'package:myweather/helpers/weather_icon_helper.dart';
import 'package:myweather/screens/city_picker_screen.dart';
import 'package:myweather/screens/weather_screen/weather_screen.dart';

import 'package:myweather/screens/hourly_forecast_screen.dart';
import 'package:myweather/services/city_storage_service.dart'; 


class WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '21cc003fb684d8f02f4fefabc56c390f';
  String city = 'Москва'; // значение по умолчанию
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    _loadCityAndFetchWeather();
  }

  Future<void> _loadCityAndFetchWeather() async {
    final storedCity = await CityStorageService().loadCity();
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
      appBar: AppBar(
        title: Text('Погода — $city'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: 'Выбрать город',
            onPressed: () async {
              final selected = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CityPickerScreen()),
              );
              if (selected != null && selected is String) {
                setState(() {
                  city = selected;
                });
                fetchWeatherData();
              }
            },
          ),
        ],
      ),
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
            padding: const EdgeInsets.only(top: 50.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: weatherData == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        _buildHeaderTile(),
                        const SizedBox(height: 2),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
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
    );
  }

  Widget _buildCustomWeatherTile(int index) {
    final parameter = widget.parameters[index];

    switch (parameter) {
      case 'temperature':
        return _createTile('Температура', '${weatherData?['main']['temp']}°C');
      case 'feelsLike':
        return _createTile(
          'Ощущается как',
          '${weatherData?['main']['feels_like']}°C',
        );
      case 'windSpeed':
        return _createTile(
          'Скорость ветра',
          '${weatherData?['wind']['speed']} м/с',
        );
      case 'windDirection':
        return _createTile(
          'Направление ветра',
          _buildCompass(weatherData?['wind']['deg'] ?? 0),
        );
      case 'humidity':
        return _createTile('Влажность', '${weatherData?['main']['humidity']}%');
      case 'pressure':
        return _createTile(
          'Давление',
          '${weatherData?['main']['pressure']} мм рт. ст.',
        );
      default:
        return _createTile('Неизвестный параметр', 'N/A');
    }
  }

  Widget _createTile(String label, dynamic value) {
    return Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(child: Center(child: _buildValueWidget(value))),
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
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(weatherIcon, size: 48, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cityName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    weatherDescription[0].toUpperCase() +
                        weatherDescription.substring(1),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HourlyForecastScreen(city: city),
                        ),
                      );
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Почасовой прогноз'),
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

  Widget _buildValueWidget(dynamic value) {
    if (value is String) {
      return Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (value is Widget) {
      return value;
    }
    return const SizedBox.shrink();
  }

  Widget _buildCompass(int degrees) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Transform.rotate(
            angle: -degrees * (3.141592653589793 / 180),
            child: Image.asset(
              'assets/compass.png',
              width: 80,
              height: 80,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_getWindDirectionText(degrees)} ($degrees°)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getWindDirectionText(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'Север';
    if (degrees >= 22.5 && degrees < 67.5) return 'Северо-восток';
    if (degrees >= 67.5 && degrees < 112.5) return 'Восток';
    if (degrees >= 112.5 && degrees < 157.5) return 'Юго-восток';
    if (degrees >= 157.5 && degrees < 202.5) return 'Юг';
    if (degrees >= 202.5 && degrees < 247.5) return 'Юго-запад';
    if (degrees >= 247.5 && degrees < 292.5) return 'Запад';
    if (degrees >= 292.5 && degrees < 337.5) return 'Северо-запад';
    return 'Неизвестно';
  }
}
