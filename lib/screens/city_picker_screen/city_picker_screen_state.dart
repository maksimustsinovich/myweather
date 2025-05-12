import 'package:flutter/material.dart';
import 'package:myweather/models/city_location.dart';
import 'package:myweather/screens/city_picker_screen/map_city_picker_screen.dart';
import 'package:myweather/services/city_storage_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({Key? key}) : super(key: key);

  @override
  State<CityPickerScreen> createState() => CityPickerScreenState();
}

class CityPickerScreenState extends State<CityPickerScreen> {
  List<CityLocation> _cities = [];
  List<String> localized = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final list = await CityStorageService().loadCities();

    if (!mounted) return;
    setState(() => _cities = list);
    if (_cities.isEmpty) {
      _pickOnMap();
    }
  }

  Future<void> _addCityManually() async {
    final controller = TextEditingController();
    final entered = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Добавить город',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Введите название города',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Отмена',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: Text(
                  'Добавить',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
    );
    if (entered?.isNotEmpty ?? false) {
      // TODO: реализовать геокодирование имени в координаты
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.push<CityLocation>(
      context,
      MaterialPageRoute(builder: (_) => const MapCityPickerScreen()),
    );
    if (result != null) {
      await CityStorageService().saveCity(result);
      _loadCities();
      Navigator.pop(context, result);
    }
  }

  Future<void> _deleteCity(CityLocation city) async {
    await CityStorageService().deleteCity(city);
    _loadCities();
  }

  void _selectCity(CityLocation city) {
    Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Выбор города', style: theme.textTheme.titleLarge),
        leading: const BackButton(color: Colors.blueAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            color: Colors.blueAccent,
            tooltip: 'Выбрать на карте',
            onPressed: _pickOnMap,
          ),
        ],
      ),
      body:
          _cities.isEmpty
              ? Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: Text(
                    'Добавить город на карте',
                    style: theme.textTheme.bodyMedium,
                  ),
                  onPressed: _pickOnMap,
                ),
              )
              : ListView.separated(
                itemCount: _cities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final city = _cities[i];
                  return ListTile(
                    title: Text(city.name, style: theme.textTheme.bodyLarge),
                    onTap: () => _selectCity(city),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteCity(city),
                    ),
                  );
                },
              ),
    );
  }
}
