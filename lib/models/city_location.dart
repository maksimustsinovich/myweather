// lib/models/city_location.dart

class CityLocation {
  String name;
  String localized;
  final double lat;
  final double lon;

  CityLocation({required this.name, required this.lat, required this.lon, this.localized = ""});

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'],
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'lat': lat, 'lon': lon};
  }
}
