// lib/services/weatherapi_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myweather/models/daily_weather_model.dart';

class WeatherApiService {
  Future<Map<String, dynamic>> _geocode(String city) async {
    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {'name': city, 'count': '1'},
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Геокодинг: ${res.statusCode}');
    final body = json.decode(res.body) as Map<String, dynamic>;
    final list = body['results'] as List<dynamic>?;
    if (list == null || list.isEmpty) throw Exception('Город не найден');
    return list.first as Map<String, dynamic>;
  }

  String _mapDescription(int code) {
    const m = {
       0:'Ясно',1:'Преимущественно ясно',2:'Переменная облачность',
       3:'Пасмурно',45:'Туман',48:'Морозный туман',51:'Лёгкая морось',
      53:'Умеренная морось',55:'Сильная морось',61:'Небольшой дождь',
      63:'Умеренный дождь',65:'Сильный дождь',71:'Небольшой снег',
      73:'Умеренный снег',75:'Сильный снег',80:'Лёгкие ливни',
      81:'Умеренные ливни',82:'Сильные ливни',95:'Гроза',
      96:'Гроза с градом',99:'Гроза с крупным градом',
    };
    return m[code] ?? 'Неизвестно';
  }

  Future<List<DailyWeather>> fetchFortnightForecast(String city) async {
    final geo = await _geocode(city);
    final lat = geo['latitude'], lon = geo['longitude'];

    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$lat',
        'longitude': '$lon',
        'daily': 'temperature_2m_min,temperature_2m_max,weathercode',
        'forecast_days': '14',
        'timezone': 'auto',
      },
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Прогноз: ${res.statusCode}');
    final body = json.decode(res.body) as Map<String, dynamic>;
    final daily = body['daily'] as Map<String, dynamic>;
    final dates = List<String>.from(daily['time']);
    final mins  = List<num>.from(daily['temperature_2m_min']);
    final maxs  = List<num>.from(daily['temperature_2m_max']);
    final codes = List<num>.from(daily['weathercode']);

    return List.generate(dates.length, (i) {
      final minT = mins[i].toDouble();
      final maxT = maxs[i].toDouble();
      final code = codes[i].toInt();
      return DailyWeather(
        date:      DateTime.parse(dates[i]),
        minTemp:   minT,
        maxTemp:   maxT,
        dayTemp:   (minT + maxT) / 2,
        weatherCode: code,
        description: _mapDescription(code),
      );
    });
  }
}
