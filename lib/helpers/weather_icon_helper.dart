import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherIconHelper {
  static IconData getWeatherIcon(int weatherId, bool isDaytime) {
    // Group 2xx: Thunderstorm
    if (weatherId >= 200 && weatherId <= 232) {
      return isDaytime
          ? WeatherIcons.day_thunderstorm
          : WeatherIcons.night_thunderstorm;
    }

    // Group 3xx: Drizzle
    if (weatherId >= 300 && weatherId <= 321) {
      return isDaytime
          ? WeatherIcons.day_sprinkle
          : WeatherIcons.night_sprinkle;
    }

    // Group 5xx: Rain
    if (weatherId == 500 || weatherId == 501) {
      return isDaytime
          ? WeatherIcons.day_rain_mix
          : WeatherIcons.night_rain_mix;
    }
    if (weatherId >= 502 && weatherId <= 504) {
      return isDaytime ? WeatherIcons.day_rain : WeatherIcons.night_rain;
    }
    if (weatherId == 511) {
      return WeatherIcons.rain_mix;
    }
    if (weatherId >= 520 && weatherId <= 531) {
      return isDaytime ? WeatherIcons.day_showers : WeatherIcons.night_showers;
    }

    // Group 6xx: Snow
    if (weatherId >= 600 && weatherId <= 602) {
      return isDaytime ? WeatherIcons.day_snow : WeatherIcons.night_snow;
    }
    if (weatherId >= 611 && weatherId <= 613) {
      return WeatherIcons.sleet;
    }
    if (weatherId == 615 || weatherId == 616) {
      return WeatherIcons.rain_mix;
    }
    if (weatherId >= 620 && weatherId <= 622) {
      return isDaytime ? WeatherIcons.day_snow : WeatherIcons.night_snow;
    }

    // Group 7xx: Atmosphere
    if (weatherId >= 701 && weatherId <= 781) {
      return WeatherIcons.fog;
    }

    // Group 800: Clear
    if (weatherId == 800) {
      return isDaytime ? WeatherIcons.day_sunny : WeatherIcons.night_clear;
    }

    // Group 80x: Clouds
    if (weatherId == 801) {
      return isDaytime ? WeatherIcons.day_cloudy : WeatherIcons.night_cloudy;
    }
    if (weatherId == 802) {
      return isDaytime
          ? WeatherIcons.day_cloudy_gusts
          : WeatherIcons.night_cloudy_gusts;
    }
    if (weatherId == 803 || weatherId == 804) {
      return isDaytime ? WeatherIcons.cloudy : WeatherIcons.cloudy;
    }

    // Default case
    return WeatherIcons.na;
  }
}