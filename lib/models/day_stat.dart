class DayStat {
  final String date;      // yyyy-MM-dd
  final int steps;
  final String weather;   // e.g. "Rain", "Clear"
  final double temp;      // средняя или текущая температура

  DayStat({
    required this.date,
    required this.steps,
    required this.weather,
    required this.temp,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'steps': steps,
        'weather': weather,
        'temp': temp,
      };

  static DayStat fromMap(Map<String, dynamic> m) => DayStat(
        date: m['date'],
        steps: m['steps'],
        weather: m['weather'],
        temp: (m['temp'] as num).toDouble(),
      );
}
