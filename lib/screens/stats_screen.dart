import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:myweather/services/db_helper.dart';

class StatsScreen extends StatefulWidget {
  final String currentWeather;
  StatsScreen({super.key, required this.currentWeather});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _todaySteps = 0;
  Map<String, double> _avgSteps = {};
  bool _isLoading = true;
  String _comparisonText = '';

  @override
  void initState() {
    super.initState();
    // Подписка на поток шагомера для реального времени
    Pedometer.stepCountStream.listen(_onStep, onError: (e) { 
      debugPrint('Ошибка шагомера: \$e');
    });
    _loadStats();
  }

  void _onStep(StepCount event) {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final eventKey = DateFormat('yyyy-MM-dd').format(event.timeStamp);
    if (eventKey == todayKey) {
      setState(() {
        _todaySteps = event.steps;
      });
      _updateComparison();
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await DBHelper.fetchDailyStatsWithWeather();
      final grouped = <String, List<int>>{};
      for (var s in stats) {
        grouped.putIfAbsent(s.weather, () => []).add(s.steps);
      }
      final avg = <String, double>{};
      grouped.forEach((weather, list) {
        final sum = list.reduce((a, b) => a + b);
        avg[weather.isNotEmpty ? weather : 'Unknown'] = sum / list.length;
      });
      setState(() {
        _avgSteps = avg;
        _isLoading = false;
      });
      _updateComparison();
    } catch (e) {
      debugPrint('Ошибка загрузки статистики: \$e');
      setState(() => _isLoading = false);
    }
  }

  void _updateComparison() {
    final avg = _avgSteps[widget.currentWeather] ?? 0;
    setState(() {
      if (avg > _todaySteps) {
        _comparisonText = 'Обычно при такой погоде шагов больше';
      } else {
        _comparisonText = 'Шагов больше, чем обычно!';
      }
    });
  }

  IconData _iconForWeather(String weather) {
    switch (weather) {
      case 'Clear': return Icons.wb_sunny;
      case 'Rain': return Icons.beach_access;
      case 'Clouds': return Icons.cloud;
      case 'Snow': return Icons.ac_unit;
      case 'Drizzle': return Icons.grain;
      case 'Thunderstorm': return Icons.flash_on;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Статистика шагов')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Статистика шагов')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Текущие шаги и текущая погода
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_iconForWeather(widget.currentWeather), size: 48),
                SizedBox(width: 8),
                Text(
                  '$_todaySteps',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(_comparisonText, style: TextStyle(fontSize: 16)),
            Divider(height: 32),
            // Список погод с иконками и средним числом шагов
            Expanded(
              child: ListView(
                children: _avgSteps.entries.map((entry) {
                  return ListTile(
                    leading: Icon(_iconForWeather(entry.key)),
                    title: Text(entry.key),
                    trailing: Text(entry.value.toStringAsFixed(0)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
