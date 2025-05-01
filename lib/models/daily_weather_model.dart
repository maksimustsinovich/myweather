// lib/models/daily_weather_model.dart

class DailyWeather {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double dayTemp;
  final String icon;
  final String description;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.dayTemp,
    required this.icon,
    required this.description,
    required this.weatherCode,
  });

  /// Парсер для OpenWeatherMap Daily (если понадобится)
  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    final w = (json['weather'] as List).first;
    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: (json['temp']['min'] as num).toDouble(),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      dayTemp: (json['temp']['day'] as num).toDouble(),
      icon: w['icon'] as String,
      description: w['description'] as String,
      weatherCode: w['id'] as int,
    );
  }

  /// Парсер для WeatherAPI.com 14‑дневного прогноза
  factory DailyWeather.fromWeatherApiJson(Map<String, dynamic> json) {
    // json['day'] содержит данные по погоде за день
    final day = json['day'] as Map<String, dynamic>;
    final cond = day['condition'] as Map<String, dynamic>;
    // icon может быть путём вида "//cdn.weatherapi.com/..."
    String rawIcon = cond['icon'] as String;
    String fullIconUrl = rawIcon.startsWith('http')
        ? rawIcon
        : 'https:$rawIcon';

    return DailyWeather(
      date: DateTime.parse(json['date'] as String),
      minTemp: (day['mintemp_c'] as num).toDouble(),
      maxTemp: (day['maxtemp_c'] as num).toDouble(),
      dayTemp: (day['avgtemp_c'] as num).toDouble(),
      icon: fullIconUrl,
      description: cond['text'] as String,
      weatherCode: (cond['code'] as num).toInt(),
    );
  }

  /// URL иконки: если icon — полный URL, возвращаем его, иначе строим для OWM
  String get iconUrl {
    if (icon.startsWith('http')) return icon;
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}
