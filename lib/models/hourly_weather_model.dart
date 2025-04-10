class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double windSpeed;
  final int pressure;
  final int weatherCode;        // <--- ДОБАВЛЕНО
  final String icon;
  final String description;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.pressure,
    required this.weatherCode,  // <--- ДОБАВЛЕНО
    required this.icon,
    required this.description,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.parse(json['dt_txt']),
      temperature: json['main']['temp'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      pressure: json['main']['pressure'],
      weatherCode: json['weather'][0]['id'],            // <--- ДОБАВЛЕНО
      icon: json['weather'][0]['icon'],
      description: json['weather'][0]['description'],
    );
  }
}
