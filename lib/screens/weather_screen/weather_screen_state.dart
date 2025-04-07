import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myweather/screens/weather_screen/weather_screen.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '21cc003fb684d8f02f4fefabc56c390f';
  final String city = 'Pekin';
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=ru';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Ошибка загрузки данных');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Погодные показатели')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            weatherData == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    _buildHeaderTile(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return _buildWeatherTile(index);
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  bool _isDayTime(String iconCode) {
    return iconCode.endsWith('d');
  }

  Widget _buildHeaderTile() {
    final cityName = weatherData?['name'] ?? 'Город';
    final date = _getFormattedDate();
    final weatherDescription =
        weatherData?['weather'][0]['description'] ?? 'Неизвестно';

    final iconCode = weatherData?['weather'][0]['icon'] ?? '';
    final isDayTime = _isDayTime(iconCode);
    final weatherIcon = _getWeatherIcon(
      weatherData?['weather'][0]['id'],
      isDayTime,
    );

    return Card(
      elevation: 4.0,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(int weatherId, bool isDaytime) {
    switch (weatherId) {
      // Group 2xx: Thunderstorm
      case 200:
      case 201:
      case 202:
      case 210:
      case 211:
      case 212:
      case 221:
      case 230:
      case 231:
      case 232:
        return isDaytime
            ? WeatherIcons.day_thunderstorm
            : WeatherIcons.night_thunderstorm;

      // Group 3xx: Drizzle
      case 300:
      case 301:
      case 302:
      case 310:
      case 311:
      case 312:
      case 313:
      case 314:
      case 321:
        return isDaytime
            ? WeatherIcons.day_sprinkle
            : WeatherIcons.night_sprinkle;

      // Group 5xx: Rain
      case 500:
      case 501:
        return isDaytime
            ? WeatherIcons.day_rain_mix
            : WeatherIcons.night_rain_mix;
      case 502:
      case 503:
      case 504:
        return isDaytime ? WeatherIcons.day_rain : WeatherIcons.night_rain;
      case 511:
        return WeatherIcons.rain_mix;
      case 520:
      case 521:
      case 522:
      case 531:
        return isDaytime
            ? WeatherIcons.day_showers
            : WeatherIcons.night_showers;

      // Group 6xx: Snow
      case 600:
      case 601:
      case 602:
        return isDaytime ? WeatherIcons.day_snow : WeatherIcons.night_snow;
      case 611:
      case 612:
      case 613:
        return WeatherIcons.sleet;
      case 615:
      case 616:
        return WeatherIcons.rain_mix;
      case 620:
      case 621:
      case 622:
        return isDaytime ? WeatherIcons.day_snow : WeatherIcons.night_snow;

      // Group 7xx: Atmosphere
      case 701:
      case 711:
      case 721:
      case 731:
      case 741:
      case 751:
      case 761:
      case 762:
      case 771:
      case 781:
        return WeatherIcons.fog;

      // Group 800: Clear
      case 800:
        return isDaytime ? WeatherIcons.day_sunny : WeatherIcons.night_clear;

      // Group 80x: Clouds
      case 801:
        return isDaytime ? WeatherIcons.day_cloudy : WeatherIcons.night_cloudy;
      case 802:
        return isDaytime
            ? WeatherIcons.day_cloudy_gusts
            : WeatherIcons.night_cloudy_gusts;
      case 803:
      case 804:
        return isDaytime ? WeatherIcons.cloudy : WeatherIcons.cloudy;

      // Default case
      default:
        return WeatherIcons.na;
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('d MMMM y, EEEE', 'ru');
    return formatter.format(now);
  }

  Widget _buildWeatherTile(int index) {
    final temperature = weatherData?['main']['temp'] ?? 'N/A';
    final feelsLike = weatherData?['main']['feels_like'] ?? 'N/A';
    final windSpeed = weatherData?['wind']['speed'] ?? 'N/A';
    final windDirection = weatherData?['wind']['deg'] ?? 0;
    final humidity = weatherData?['main']['humidity'] ?? 0;
    final pressure = weatherData?['main']['pressure'] ?? 'N/A';

    final List<Map<String, dynamic>> weatherTiles = [
      {'label': 'Температура', 'value': '$temperature°C'},
      {'label': 'Ощущается как', 'value': '$feelsLike°C'},
      {'label': 'Скорость ветра', 'value': '$windSpeed м/с'},
      {'label': 'Направление ветра', 'value': windDirection},
      {'label': 'Влажность', 'value': humidity / 100},
      {'label': 'Давление', 'value': '$pressure мм рт. ст.'},
    ];

    final data = weatherTiles[index];

    return Card(
      elevation: 4.0,
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
              data['label'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(child: Center(child: _buildValueWidget(data['value']))),
        ],
      ),
    );
  }

  Widget _buildValueWidget(dynamic value) {
    if (value is String) {
      return Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (value is int) {
      return _buildCompass(value);
    } else if (value is double) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      );
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
