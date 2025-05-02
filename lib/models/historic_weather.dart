class HistoricWeather {
  final String main;   // например, "Rain", "Clear"
  final double temp;   // температура в °C

  HistoricWeather({required this.main, required this.temp});

  factory HistoricWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final weather = (current['weather'] as List).first as Map<String, dynamic>;
    return HistoricWeather(
      main: weather['main'] as String,
      temp: (current['temp'] as num).toDouble(),
    );
  }
}
