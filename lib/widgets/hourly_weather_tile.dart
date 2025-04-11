import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/models/hourly_weather_model.dart';

class HourlyWeatherTile extends StatelessWidget {
  final HourlyWeather data;

  const HourlyWeatherTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.6)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat.Hm('ru').format(data.time),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Image.network(
            'https://openweathermap.org/img/wn/${data.icon}@2x.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 6),
          Text(
            '${data.temperature.round()}°C',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
