import 'package:flutter/material.dart';
import 'package:myweather/screens/city_picker_screen/map_city_picker_screen.dart';
import 'package:myweather/services/city_storage_service.dart';

class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({Key? key}) : super(key: key);

  @override
  State<CityPickerScreen> createState() => CityPickerScreenState();
}

class CityPickerScreenState extends State<CityPickerScreen> {
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final list = await CityStorageService().loadCities();
    if (!mounted) return;
    setState(() => _cities = list);
    // Если нет сохранённых городов, сразу открываем карту
    if (_cities.isEmpty) {
      _pickOnMap();
    }
  }

  Future<void> _addCityManually() async {
    final controller = TextEditingController();
    final entered = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Добавить город'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Введите название города'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (entered?.isNotEmpty ?? false) {
      await CityStorageService().saveCity(entered!);
      _loadCities();
    }
  }

  Future<void> _pickOnMap() async {
    final cityFromMap = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapCityPickerScreen()),
    );
    if (cityFromMap != null && cityFromMap.isNotEmpty) {
      await CityStorageService().saveCity(cityFromMap);
      _loadCities();
      // Закрываем экран выбора, возвращая город в WeatherScreen
      Navigator.pop(context, cityFromMap);
    }
  }

  Future<void> _deleteCity(String city) async {
    await CityStorageService().deleteCity(city);
    _loadCities();
  }

  void _selectCity(String city) {
    Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор города'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Выбрать на карте',
            onPressed: _pickOnMap,
          ),
        ],
      ),
      body: _cities.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Добавить город на карте'),
                onPressed: _pickOnMap,
              ),
            )
          : ListView.separated(
              itemCount: _cities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final city = _cities[i];
                return ListTile(
                  title: Text(city),
                  onTap: () => _selectCity(city),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteCity(city),
                  ),
                );
              },
            ),
      floatingActionButton: _cities.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _addCityManually,
              tooltip: 'Добавить город вручную',
              child: const Icon(Icons.add),
            ),
    );
  }
}
