// temporary model to hold data
class LatLng {
  final double lat;
  final double lng;

  LatLng({required this.lat, required this.lng});

  factory LatLng.fromJson(Map<String, dynamic> parsedJson) {
    return LatLng(
      lat: parsedJson['lat'] as double,
      lng: parsedJson['lng'] as double,
    );
  }
}
