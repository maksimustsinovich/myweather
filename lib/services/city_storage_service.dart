// lib/services/city_storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myweather/models/city_location.dart';

// lib/services/city_storage_service.dart

class CityStorageService {
  static const String _key = 'saved_cities';
  static const String _lastCityKey = 'last_selected_city';

  Future<List<CityLocation>> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getStringList(_key) ?? [];
    return citiesJson
        .map((json) => CityLocation.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveCity(CityLocation city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final newEntry = jsonEncode(city.toJson());
    if (!list.contains(newEntry)) {
      list.add(newEntry);
      await prefs.setStringList(_key, list);
    }
  }

  Future<void> deleteCity(CityLocation city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final encoded = jsonEncode(city.toJson());
    list.removeWhere((item) => item == encoded);
    await prefs.setStringList(_key, list);
  }

  // 🔁 Получить последний выбранный город
  Future<CityLocation?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCityJson = prefs.getString(_lastCityKey);
    if (lastCityJson != null) {
      return CityLocation.fromJson(jsonDecode(lastCityJson));
    }
    return null;
  }

  // 🔁 Сохранить последний выбранный город
  Future<void> saveLastCity(CityLocation city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, jsonEncode(city.toJson()));
  }
}
