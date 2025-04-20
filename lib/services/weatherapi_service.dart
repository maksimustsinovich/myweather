import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myweather/models/daily_weather_model.dart';

class WeatherApiService {
  /// Ваш ключ с weatherapi.com
  final String apiKey = '026ef2b57bdd466cbb0202834251904';

Future<List<DailyWeather>> fetchFortnightForecast(String city) async {
    final uri = Uri.https(
      'api.weatherapi.com',
      '/v1/forecast.json',
      {
        'key': apiKey,
        'q': city,
        'days': '14',
        'aqi': 'no',
        'alerts': 'no',
        'lang': 'ru',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Ошибка: ${response.statusCode}');
    }

    // ВАЖНО: берём bodyBytes и декодируем как UTF-8
    final decoded = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decoded) as Map<String, dynamic>;

    final List list = data['forecast']['forecastday'] as List;
    return list
      .cast<Map<String, dynamic>>()
      .map((e) => DailyWeather.fromWeatherApiJson(e))
      .toList();
  }
}