import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/models/hourly_weather_model.dart';

/// Виджет для отображения прогноза на 5 дней.
/// Для каждого дня вычисляются минимальная и максимальная температура
/// по данным из [fullData]. При нажатии вызывается [onSelect] с датой в формате "yyyy-MM-dd".
class ForecastDaySelector extends StatelessWidget {
  final List<String> dates;             // Список дат, например: ['2023-04-10', '2023-04-11', ...]
  final String selectedDate;            // Выбранная дата
  final void Function(String) onSelect; // Обработчик выбора даты
  final List<HourlyWeather> fullData;   // Полный список почасовых прогнозов

  const ForecastDaySelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onSelect,
    required this.fullData,
  });

  @override
  Widget build(BuildContext context) {
    // Отображаем не более 5 ближайших дней.
    final daysToShow = dates.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Заголовок и кнопка "Подробнее"
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
                onPressed: () {
                  // Добавьте логику для кнопки "Подробнее", если требуется.
                },
                child: const Text('Подробнее'),
              ),
            ],
          ),
        ),
        // Список дней (каждый день в отдельной строке)
        ...daysToShow.map((dateStr) {
          return _buildDayRow(context, dateStr);
        }),
        const SizedBox(height: 8),
        // Дополнительная кнопка "Прогноз на 5 дней" (если требуется)
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
              // Добавьте логику при нажатии
            },
            child: const Text(
              'Прогноз на 5 дней',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// Строим строку для одного дня.
  Widget _buildDayRow(BuildContext context, String dateStr) {
    final date = DateTime.parse(dateStr);
    final dayLabel = _getDayLabel(date);
    final isSelected = selectedDate == dateStr;

    // Фильтруем почасовые данные за этот день.
    final dayData = fullData.where((item) {
      return DateFormat('yyyy-MM-dd').format(item.time) == dateStr;
    }).toList();

    if (dayData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Вычисляем минимальную и максимальную температуру за день.
    final double dayMin = dayData
        .map((w) => w.temperature)
        .reduce((a, b) => a < b ? a : b);
    final double dayMax = dayData
        .map((w) => w.temperature)
        .reduce((a, b) => a > b ? a : b);

    // Берем иконку первого часа (можно менять по желанию).
    final icon = dayData.first.icon;

    // Если выбран, выделяем цветом фон.
    final bgColor = isSelected ? Colors.white.withOpacity(0.15) : null;

    return InkWell(
      onTap: () => onSelect(dateStr),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Левая часть: название дня и иконка.
            Row(
              children: [
                Text(
                  dayLabel,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Image.network(
                  'https://openweathermap.org/img/wn/$icon@2x.png',
                  width: 32,
                  height: 32,
                ),
              ],
            ),
            // Правая часть: минимальная и максимальная температура.
            Row(
              children: [
                Text(
                  '${dayMin.round()}°',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                _buildTempBar(),
                const SizedBox(width: 8),
                Text(
                  '${dayMax.round()}°',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Простейший индикатор, можно заменить на динамический график.
  Widget _buildTempBar() {
    return Container(
      width: 50,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  /// Функция определяет название дня: "Сегодня", "Завтра" или сокращенное название дня недели.
  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final tomorrowStr =
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    if (dateStr == todayStr) return 'Сегодня';
    if (dateStr == tomorrowStr) return 'Завтра';

    final weekday = DateFormat('EEEE', 'ru').format(date).toLowerCase();
    switch (weekday) {
      case 'понедельник':
        return 'Пн';
      case 'вторник':
        return 'Вт';
      case 'среда':
        return 'Ср';
      case 'четверг':
        return 'Чт';
      case 'пятница':
        return 'Пт';
      case 'суббота':
        return 'Сб';
      case 'воскресенье':
        return 'Вс';
      default:
        return weekday.substring(0, 2);
    }
  }
}
