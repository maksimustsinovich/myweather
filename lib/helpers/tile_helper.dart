import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myweather/helpers/weather_icon_helper.dart';
import 'package:myweather/screens/hourly_forecast_screen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:weather_icons/weather_icons.dart';

class TileHelper {
  static final Color accentColor = Colors.blueAccent;

  static Widget buildTemperatureGauge(double temperature) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: -20,
            maximum: 40,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(value: temperature, width: 10, color: accentColor),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thermostat, color: accentColor, size: 36),
                  ],
                ),
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildHumidityGauge(double humidity) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(value: humidity, width: 10, color: accentColor),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, color: accentColor, size: 36),
                  ],
                ),
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildPressureGauge(double pressure) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 700,
            maximum: 1200,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(value: pressure, width: 10, color: accentColor),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.speed, color: accentColor, size: 36)],
                ),
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildWindTile({
    required Map<String, dynamic>? weatherData,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    TextStyle? windDirectionStyle,
    TextStyle? windSpeedStyle,
  }) {
    final windSpeed = weatherData?['wind']['speed'] ?? 'N/A';
    final windDirectionDegrees = weatherData?['wind']['deg'] ?? 0;
    final windDirectionText = WeatherIconHelper.getWindDirectionText(
      windDirectionDegrees,
    );

    return Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ветер', style: labelStyle),
                const SizedBox(height: 8),
                Text(
                  '$windDirectionText ($windDirectionDegrees°)',
                  style: windDirectionStyle,
                ),
                const SizedBox(height: 4),
                Text('$windSpeed м/с', style: windSpeedStyle),
              ],
            ),
          ),
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: buildCompass(windDirectionDegrees),
          ),
        ],
      ),
    );
  }

  static Widget buildTile({
    required String label,
    required String value,
    Widget? widget,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      labelStyle ??
                      const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style:
                      valueStyle ??
                      const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          if (widget != null)
            Positioned(bottom: 8.0, right: 8.0, child: widget),
        ],
      ),
    );
  }

  static bool getIsDayTime(String iconCode) {
    return iconCode.endsWith('d');
  }

  static Widget buildHeaderTile(
    Map<String, dynamic>? weatherData,
    BuildContext context,
  ) {
    final cityName = weatherData?['name'] ?? 'Город';
    final date = getFormattedDate(weatherData?['dt']);
    final weatherDescription =
        weatherData?['weather'][0]['description'] ?? 'Неизвестно';
    final iconCode = weatherData?['weather'][0]['icon'] ?? '';
    final isDayTime = getIsDayTime(iconCode);
    final weatherIcon = WeatherIconHelper.getWeatherIcon(
      weatherData?['weather'][0]['id'],
      isDayTime,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HourlyForecastScreen(city: cityName),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(weatherIcon, size: 64, color: accentColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cityName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(date, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      weatherDescription[0].toUpperCase() +
                          weatherDescription.substring(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String getFormattedDate(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final formatter = DateFormat('d MMMM y, EEEE', 'ru');
    return formatter.format(dateTime);
  }

  static Widget buildSunPhasesTile(
    Map<String, dynamic>? weatherData, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final sunrise = weatherData?['sys']['sunrise'] ?? 0;
    final sunset = weatherData?['sys']['sunset'] ?? 0;
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
    final now = DateTime.now();
    final currentTime = now.millisecondsSinceEpoch / 1000;

    String phase = 'Ночь';
    if (currentTime > sunrise && currentTime < sunset) {
      phase = 'День';
      if (currentTime <
          sunsetTime.subtract(const Duration(hours: 4)).millisecondsSinceEpoch /
              1000) {
        phase = 'Утро';
      }
    } else {
      phase = 'Вечер';
    }

    return Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Фазы дня', style: labelStyle),
                const SizedBox(height: 8),
                Text(phase, style: valueStyle),
              ],
            ),
          ),
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: buildSunPhaseGauge(sunriseTime, sunsetTime, now),
          ),
        ],
      ),
    );
  }

  static Widget buildSunPhaseGauge(
    DateTime sunriseTime,
    DateTime sunsetTime,
    DateTime now,
  ) {
    // Общая продолжительность дня (от восхода до заката)
    final totalDayDuration =
        sunsetTime.millisecondsSinceEpoch - sunriseTime.millisecondsSinceEpoch;

    // Продолжительность ночи до восхода и после заката
    final dayStart =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final nightBeforeSunrise = sunriseTime.millisecondsSinceEpoch - dayStart;
    final nightAfterSunset =
        dayStart +
        86400000 -
        sunsetTime.millisecondsSinceEpoch; // 86400000 мс = 24 ч

    // Рассчитываем процентное распределение времени суток
    double progress = 0;
    String currentPhase = 'night';

    if (now.isBefore(sunriseTime)) {
      progress =
          (now.millisecondsSinceEpoch - dayStart) / nightBeforeSunrise * 25;
      currentPhase = 'night';
    } else if (now.isAfter(sunsetTime)) {
      progress =
          75 +
          ((now.millisecondsSinceEpoch - sunsetTime.millisecondsSinceEpoch) /
              nightAfterSunset *
              25);
      currentPhase = 'evening';
    } else if (now.isAfter(sunriseTime) && now.isBefore(sunsetTime)) {
      final dayProgress =
          now.millisecondsSinceEpoch - sunriseTime.millisecondsSinceEpoch;
      progress = 25 + (dayProgress / totalDayDuration * 50);
      currentPhase = 'day';
    }

    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270 + 360,
            axisLineStyle: AxisLineStyle(
              thickness: 10,
              color: Colors.grey[300],
              thicknessUnit: GaugeSizeUnit.logicalPixel,
            ),
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: 25,
                color: Colors.blueAccent, // Ночь
              ),
              GaugeRange(
                startValue: 25,
                endValue: 50,
                color: Colors.yellow, // Утро
              ),
              GaugeRange(
                startValue: 50,
                endValue: 75,
                color: Colors.orange, // День
              ),
              GaugeRange(
                startValue: 75,
                endValue: 100,
                color: Colors.orangeAccent, // Вечер
              ),
            ],
            pointers: <GaugePointer>[
              RangePointer(
                value: progress,
                width: 10,
                color: Colors.black,
                enableAnimation: true,
                animationDuration: 500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildCompass(int degrees) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: 0,
            endAngle: 360,
            radiusFactor: 0.9,
            minimum: 0,
            maximum: 360,
            axisLineStyle: AxisLineStyle(
              thicknessUnit: GaugeSizeUnit.logicalPixel,
              thickness: 5,
              color: accentColor,
            ),
            onLabelCreated: WeatherIconHelper.labelCreated,
            interval: 45,
            canRotateLabels: true,
            axisLabelStyle: GaugeTextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            labelOffset: 0,
            minorTicksPerInterval: 0,
            majorTickStyle: MajorTickStyle(
              thickness: 1.5,
              lengthUnit: GaugeSizeUnit.factor,
              length: 0.07,
            ),
            showLabels: true,
            pointers: <GaugePointer>[
              NeedlePointer(
                value: degrees.toDouble(),
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFFFF6B78),
                    Color(0xFFFF6B78),
                    Color(0xFFE20A22),
                    Color(0xFFE20A22),
                  ],
                  stops: <double>[0, 0.5, 0.5, 1],
                ),
                needleEndWidth: 4,
                needleStartWidth: 1,
                needleLength: 0.6,
                knobStyle: KnobStyle(
                  knobRadius: 0.08,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.black,
                ),
              ),
              NeedlePointer(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFFE3DFDF),
                    Color(0xFFE3DFDF),
                    Color(0xFF7A7A7A),
                    Color(0xFF7A7A7A),
                  ],
                  stops: <double>[0, 0.5, 0.5, 1],
                ),
                value: (degrees + 180) % 360,
                needleEndWidth: 4,
                needleStartWidth: 1,
                needleLength: 0.6,
                knobStyle: KnobStyle(
                  knobRadius: 0.08,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
