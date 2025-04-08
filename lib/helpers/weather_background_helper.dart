import 'package:flutter/material.dart';
import 'package:myweather/consts/weather_backgrounds.dart';
import 'package:myweather/consts/weather_conditions.dart';

class WeatherBackgroundHelper {
  static ImageProvider getBackgroundImage(int weatherId) {
    if (weatherId >= WeatherConstants.thunderstormLightRain &&
        weatherId <= WeatherConstants.thunderstormHeavyDrizzle) {
      return AssetImage(WeatherBackgrounds.thunderstormImage);
    } else if (weatherId >= WeatherConstants.lightIntensityDrizzle &&
        weatherId <= WeatherConstants.showerDrizzle) {
      return AssetImage(WeatherBackgrounds.drizzleImage);
    } else if (weatherId >= WeatherConstants.lightRain &&
        weatherId <= WeatherConstants.extremeRain) {
      return AssetImage(WeatherBackgrounds.rainImage);
    } else if (weatherId >= WeatherConstants.lightSnow &&
        weatherId <= WeatherConstants.heavyShowerSnow) {
      return AssetImage(WeatherBackgrounds.snowImage);
    } else if (weatherId >= WeatherConstants.mist &&
        weatherId <= WeatherConstants.tornado) {
      return AssetImage(WeatherBackgrounds.fogImage);
    } else if (weatherId == WeatherConstants.clearSky) {
      return AssetImage(WeatherBackgrounds.clearImage);
    } else if (weatherId >= WeatherConstants.fewClouds &&
        weatherId <= WeatherConstants.overcastClouds) {
      return AssetImage(WeatherBackgrounds.cloudImage);
    } else {
      return AssetImage(WeatherBackgrounds.clearImage);
    }
  }
}
