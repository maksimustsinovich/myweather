import 'package:flutter/material.dart';
import 'package:myweather/consts/weather_conditions.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
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
    if (weatherId == WeatherConstants.mist) {
      return isDaytime ? WeatherIcons.day_haze : WeatherIcons.fog;
    }
    if (weatherId == WeatherConstants.smoke) {
      return WeatherIcons.smoke;
    }
    if (weatherId == WeatherConstants.haze) {
      return isDaytime ? WeatherIcons.day_haze : WeatherIcons.fog;
    }
    if (weatherId == WeatherConstants.sandDustWhirls) {
      return WeatherIcons.sandstorm;
    }
    if (weatherId == WeatherConstants.fog) {
      return WeatherIcons.fog;
    }
    if (weatherId == WeatherConstants.sand) {
      return WeatherIcons.sandstorm;
    }
    if (weatherId == WeatherConstants.dust) {
      return WeatherIcons.dust;
    }
    if (weatherId == WeatherConstants.volcanicAsh) {
      return WeatherIcons.volcano;
    }
    if (weatherId == WeatherConstants.squalls) {
      return WeatherIcons.strong_wind;
    }
    if (weatherId == WeatherConstants.tornado) {
      return WeatherIcons.tornado;
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

    return WeatherIcons.na;
  }

  static void labelCreated(AxisLabelCreatedArgs args) {
    if (args.text == '360' || args.text == '0') {
      args.text = 'С';
    } else if (args.text == '45') {
      args.text = 'С-В';
    } else if (args.text == '90') {
      args.text = 'В';
    } else if (args.text == '135') {
      args.text = 'Ю-В';
    } else if (args.text == '180') {
      args.text = 'Ю';
    } else if (args.text == '225') {
      args.text = 'Ю-З';
    } else if (args.text == '270') {
      args.text = 'З';
    } else if (args.text == '315') {
      args.text = 'С-З';
    }
  }

  static String getWindDirectionText(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'С';
    if (degrees >= 22.5 && degrees < 67.5) return 'С-В';
    if (degrees >= 67.5 && degrees < 112.5) return 'В';
    if (degrees >= 112.5 && degrees < 157.5) return 'Ю-В';
    if (degrees >= 157.5 && degrees < 202.5) return 'Ю';
    if (degrees >= 202.5 && degrees < 247.5) return 'Ю-З';
    if (degrees >= 247.5 && degrees < 292.5) return 'З';
    if (degrees >= 292.5 && degrees < 337.5) return 'С-З';
    return 'Неизвестно';
  }
}
