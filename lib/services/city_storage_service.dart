import 'package:shared_preferences/shared_preferences.dart';

class CityStorageService {
  static const _key = 'savedCities';

  Future<List<String>> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];

    if (!existing.contains(city)) {
      existing.add(city);
      await prefs.setStringList(_key, existing);
    }
  }

  Future<String?> getLastCity() async {
  final cities = await loadCities();
  return cities.isNotEmpty ? cities.last : null;
}


  Future<void> deleteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.remove(city);
    await prefs.setStringList(_key, existing);
  }
}
