import 'package:flutter/material.dart';
import 'package:myweather/consts/weather_conditions.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherIconHelper {
  static IconData getWeatherIcon(int weatherId, bool isDaytime) {
    // Group 2xx: Thunderstorm
    if (weatherId >= WeatherConstants.thunderstormLightRain &&
        weatherId <= WeatherConstants.thunderstormHeavyDrizzle) {
      return isDaytime
          ? WeatherIcons.day_thunderstorm
          : WeatherIcons.night_thunderstorm;
    }

    // Group 3xx: Drizzle
    if (weatherId >= WeatherConstants.lightIntensityDrizzle &&
        weatherId <= WeatherConstants.showerDrizzle) {
      return isDaytime
          ? WeatherIcons.day_sprinkle
          : WeatherIcons.night_sprinkle;
    }

    // Group 5xx: Rain
    if (weatherId >= WeatherConstants.lightRain &&
        weatherId <= WeatherConstants.moderateRain) {
      return isDaytime
          ? WeatherIcons.day_rain_mix
          : WeatherIcons.night_rain_mix;
    }
    if (weatherId >= WeatherConstants.heavyIntensityRain &&
        weatherId <= WeatherConstants.extremeRain) {
      return isDaytime ? WeatherIcons.day_rain : WeatherIcons.night_rain;
    }
    if (weatherId == WeatherConstants.freezingRain) {
      return WeatherIcons.rain_mix;
    }
    if (weatherId >= WeatherConstants.lightIntensityShowerRain &&
        weatherId <= WeatherConstants.raggedShowerRain) {
      return isDaytime ? WeatherIcons.day_showers : WeatherIcons.night_showers;
    }

    // Group 6xx: Snow
    if (weatherId >= WeatherConstants.lightSnow &&
        weatherId <= WeatherConstants.heavySnow) {
      return isDaytime ? WeatherIcons.day_snow : WeatherIcons.night_snow;
    }
    if (weatherId >= WeatherConstants.sleet &&
        weatherId <= WeatherConstants.showerSleet) {
      return WeatherIcons.sleet;
    }
    if (weatherId >= WeatherConstants.lightRainAndSnow &&
        weatherId <= WeatherConstants.rainAndSnow) {
      return WeatherIcons.rain_mix;
    }
    if (weatherId >= WeatherConstants.lightShowerSnow &&
        weatherId <= WeatherConstants.heavyShowerSnow) {
      return isDaytime ? WeatherIcons.day_snow : WeatherIcons.night_snow;
    }

    // Group 7xx: Atmosphere
    if (weatherId >= WeatherConstants.mist &&
        weatherId <= WeatherConstants.tornado) {
      return WeatherIcons.fog;
    }

    // Group 800: Clear
    if (weatherId == WeatherConstants.clearSky) {
      return isDaytime ? WeatherIcons.day_sunny : WeatherIcons.night_clear;
    }

    // Group 80x: Clouds
    if (weatherId == WeatherConstants.fewClouds) {
      return isDaytime ? WeatherIcons.day_cloudy : WeatherIcons.night_cloudy;
    }
    if (weatherId == WeatherConstants.scatteredClouds) {
      return isDaytime
          ? WeatherIcons.day_cloudy_gusts
          : WeatherIcons.night_cloudy_gusts;
    }
    if (weatherId >= WeatherConstants.brokenClouds &&
        weatherId <= WeatherConstants.overcastClouds) {
      return isDaytime ? WeatherIcons.cloudy : WeatherIcons.cloudy;
    }

    // Default case
    return WeatherIcons.na;
  }
}
