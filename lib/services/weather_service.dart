import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myweather/models/daily_weather_model.dart';
import 'package:myweather/models/hourly_weather_model.dart';

class WeatherService {
  final String apiKey = 'a3c40fb14044f1cd8590545be3d9d92d';

Future<List<HourlyWeather>> fetchHourlyForecast(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=ru';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];
      return list
          .map((item) => HourlyWeather.fromJson(item))
          .toList();
    } else {
      throw Exception(
          'Ошибка загрузки прогноза: ${response.statusCode} — ${response.reasonPhrase}');
    }
  }

}