// lib/widgets/forecast_day_selector.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/models/hourly_weather_model.dart';
import 'package:myweather/screens/monthly_forecast_screen.dart';

/// Прогноз на 5 дней + кнопка перехода на 2 недели
class ForecastDaySelector extends StatelessWidget {
  final List<String> dates;
  final String selectedDate;
  final void Function(String) onSelect;
  final List<HourlyWeather> fullData;
  final String city;
  final int weatherId; // <-- новое поле

  const ForecastDaySelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onSelect,
    required this.fullData,
    required this.city,
    required this.weatherId, // <-- требуем его
  });

  @override
  Widget build(BuildContext context) {
    final daysToShow = dates.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                'Прогноз на 5 дней',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () {/* опционально */},
                child: const Text('Подробнее'),
              ),
            ],
          ),
        ),
        ...daysToShow.map((d) => _buildDayRow(context, d)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthlyForecastScreen(
                    city: city,
                    initialWeatherId: weatherId, // <-- прокидываем сюда
                  ),
                ),
              );
            },
            child: const Text('Прогноз на 2 недели'),
          ),
        ),
      ],
    );
  }

  Widget _buildDayRow(BuildContext context, String dateStr) {
    final date = DateTime.parse(dateStr);
    final label = _getDayLabel(date);
    final isSelected = selectedDate == dateStr;
    final dayData = fullData.where((w) =>
      DateFormat('yyyy-MM-dd').format(w.time) == dateStr).toList();
    if (dayData.isEmpty) return const SizedBox.shrink();

    final minT = dayData.map((w) => w.temperature).reduce((a, b) => a < b ? a : b);
    final maxT = dayData.map((w) => w.temperature).reduce((a, b) => a > b ? a : b);
    final icon = dayData.first.icon;
    final bg = isSelected ? Colors.white.withOpacity(0.15) : null;

    return InkWell(
      onTap: () => onSelect(dateStr),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text(label, style: const TextStyle(fontSize:16,color:Colors.white)),
              const SizedBox(width:8),
              Image.network('https://openweathermap.org/img/wn/$icon@2x.png',width:32,height:32),
            ]),
            Text('${minT.round()}° – ${maxT.round()}°',
              style: const TextStyle(fontSize:16,color:Colors.white)),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(DateTime d) {
    final now = DateTime.now();
    final s = DateFormat('yyyy-MM-dd').format;
    if (s(d)==s(now)) return 'Сегодня';
    if (s(d)==s(now.add(const Duration(days:1)))) return 'Завтра';
    switch (DateFormat('EEEE','ru').format(d).toLowerCase()) {
      case 'понедельник': return 'Пн';
      case 'вторник':     return 'Вт';
      case 'среда':       return 'Ср';
      case 'четверг':     return 'Чт';
      case 'пятница':     return 'Пт';
      case 'суббота':     return 'Сб';
      case 'воскресенье': return 'Вс';
      default: return DateFormat('EE','ru').format(d);
    }
  }
}
