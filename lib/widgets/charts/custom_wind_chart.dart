import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/models/hourly_weather_model.dart';

class CustomWindChart extends StatelessWidget {
  final List<HourlyWeather> data;

  const CustomWindChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      double x = data[i].time.difference(data[0].time).inHours.toDouble();
      spots.add(FlSpot(x, data[i].windSpeed));
    }

    return Card(
      color: Colors.white.withOpacity(0.6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Ветер (м/с)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black87),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 3,
                        getTitlesWidget: (value, meta) {
                          final match = data.firstWhere(
                              (item) =>
                                  item.time
                                          .difference(data[0].time)
                                          .inHours
                                          .toDouble() ==
                                      value,
                              orElse: () => data.first);
                          return Text(DateFormat.Hm('ru').format(match.time),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black87));
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
