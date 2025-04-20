// lib/screens/city_picker_screen/map_city_picker_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myweather/services/city_storage_service.dart';

class MapCityPickerScreen extends StatefulWidget {
  const MapCityPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapCityPickerScreen> createState() => MapCityPickerScreenState();
}

class MapCityPickerScreenState extends State<MapCityPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _suggestions = [];
  Marker? _marker;

  // Минск по умолчанию
  LatLng _center = const LatLng(53.9, 27.5667);
  double _currentZoom = 10.0;

  /// Запрос к Nominatim для получения подсказок
  Future<void> _onSearchChanged(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?format=json&q=$query&addressdetails=1&limit=5',
    );
    final resp = await http.get(uri, headers: {'User-Agent': 'myweather-app'});
    final List data = jsonDecode(resp.body);
    setState(() => _suggestions = data.cast<Map<String, dynamic>>());
  }

  /// Обратное геокодирование для получения названия города
  Future<String?> _reverseGeocode(LatLng pos) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=json&lat=${pos.latitude}&lon=${pos.longitude}&addressdetails=1',
    );
    final resp = await http.get(uri, headers: {'User-Agent': 'myweather-app'});
    final json = jsonDecode(resp.body);
    return json['address']['city']
        ?? json['address']['town']
        ?? json['address']['village']
        ?? json['display_name'];
  }

  /// Ставит маркер и перемещает карту
  void _setMarker(LatLng pos) {
    setState(() {
      _marker = Marker(
        point: pos,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
      );
      _center = pos;
      _mapController.move(pos, _currentZoom);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Найти город на карте')),
      body: Column(
        children: [
          // 1) Поисковое поле
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Найдите город или район',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // 2) Список подсказок
          if (_suggestions.isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final sug = _suggestions[i];
                  return ListTile(
                    title: Text(sug['display_name']),
                    onTap: () {
                      final lat = double.parse(sug['lat']);
                      final lon = double.parse(sug['lon']);
                      _setMarker(LatLng(lat, lon));
                      _searchCtrl.text = sug['display_name'];
                      setState(() => _suggestions = []);
                    },
                  );
                },
              ),
            ),

          // 3) Карта
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _currentZoom,
                onPositionChanged: (pos, _) {
                  _currentZoom = pos.zoom ?? _currentZoom;
                },
                onTap: (_, tapPos) => _setMarker(
                  LatLng(tapPos.latitude, tapPos.longitude),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.myweather',
                ),
                if (_marker != null) MarkerLayer(markers: [_marker!]),
              ],
            ),
          ),

          // 4) Сохранить город
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _marker == null
                  ? null
                  : () async {
                      final city = await _reverseGeocode(_marker!.point);
                      if (city != null && mounted) {
                        await CityStorageService().saveCity(city);
                        Navigator.pop(context, city);
                      }
                    },
              child: const Text('Сохранить город'),
            ),
          ),
        ],
      ),
    );
  }
}
