import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastDaySelector extends StatelessWidget {
  final List<String> dates;          // список доступных дат в формате 'yyyy-MM-dd'
  final String selectedDate;         // текущая выбранная дата
  final void Function(String) onSelect; // обработчик выбора даты

  const ForecastDaySelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final parsedDate = DateTime.parse(date);
          final label = DateFormat.E('ru').format(parsedDate); // Пн, Вт и т.д.
          final isSelected = selectedDate == date;

          return GestureDetector(
            onTap: () => onSelect(date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${parsedDate.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}