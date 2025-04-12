import 'package:flutter/material.dart';
import 'package:myweather/screens/city_picker_screen/city_picker_screen.dart';
import 'package:myweather/services/city_storage_service.dart';

class CityPickerScreenState extends State<CityPickerScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> savedCities = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final cities = await CityStorageService().loadCities();
    setState(() {
      savedCities = cities;
    });
  }

  Future<void> _addCity() async {
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    await CityStorageService().saveCity(city);
    _controller.clear();
    _loadCities();
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
      appBar: AppBar(title: const Text('Выбор города')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите название города',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addCity(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCity,
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: savedCities.isEmpty
                ? const Center(child: Text('Список пуст'))
                : ListView.builder(
                    itemCount: savedCities.length,
                    itemBuilder: (_, index) {
                      final city = savedCities[index];
                      return ListTile(
                        title: Text(city),
                        onTap: () => _selectCity(city),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCity(city),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
