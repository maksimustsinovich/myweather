import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/city_storage_service.dart';

class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({super.key});

  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  LatLng _mapCenter = LatLng(55.751244, 37.618423); // Москва по умолчанию
  final MapController _mapController = MapController();
  String _selectedCity = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _mapCenter = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(_mapCenter, 10);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    return permission != LocationPermission.deniedForever;
  }

  Future<void> _searchCity(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5',
    );
    final response = await http.get(url, headers: {
      'User-Agent': 'myweather-app'
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _searchResults = data.map<Map<String, dynamic>>((e) => e).toList();
      });
    }
  }

  void _selectCity(Map<String, dynamic> result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);

    final address = result['address'];
    final cityName = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['state'] ??
        'Неизвестно';

    setState(() {
      _mapCenter = LatLng(lat, lon);
      _selectedCity = cityName;
      _mapController.move(_mapCenter, 12);
      _searchResults.clear();
      _searchController.text = cityName;
    });
  }

  Future<void> _saveCity() async {
    if (_selectedCity.isNotEmpty) {
      await CityStorageService().saveCity(_selectedCity);
      if (context.mounted) Navigator.pop(context, _selectedCity);
    }
  }

  Future<void> _useCurrentLocation() async {
  final hasPermission = await _handleLocationPermission();
  if (!hasPermission) return;

  final position = await Geolocator.getCurrentPosition();
  final lat = position.latitude;
  final lon = position.longitude;

  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
  );

  final response = await http.get(url, headers: {
    'User-Agent': 'myweather-app'
  });

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final address = data['address'];
    final cityName = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['state'] ??
        'Неизвестно';

    setState(() {
      _mapCenter = LatLng(lat, lon);
      _selectedCity = cityName;
      _mapController.move(_mapCenter, 12);
      _searchController.text = cityName;
      _searchResults.clear();
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор города')),
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Введите название города...',
        ),
        onSubmitted: _searchCity,
      ),
    ),

    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          icon: const Icon(Icons.my_location),
          label: const Text('Использовать текущее местоположение'),
          onPressed: _useCurrentLocation,
        ),
      ),
    ),

    if (_searchResults.isNotEmpty)
      SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (_, index) {
            final result = _searchResults[index];
            final displayName = result['display_name'];
            return ListTile(
              title: Text(displayName),
              onTap: () => _selectCity(result),
            );
          },
        ),
      ),

    Expanded(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _mapCenter,
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.myweather',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: _mapCenter,
                child: const Icon(Icons.location_pin,
                    size: 40, color: Colors.red),
              )
            ],
          ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: _saveCity,
        child: const Text('Сохранить город'),
      ),
    )
  ],
),

    );
  }
}
