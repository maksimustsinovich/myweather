import 'package:shared_preferences/shared_preferences.dart';

class CityStorageService {
  static const String _key = 'selectedCity';

  Future<void> saveCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, cityName);
  }

  Future<String?> loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
