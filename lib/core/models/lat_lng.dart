// temporary model to hold data
class PlaceLatLng {
  final double lat;
  final double lng;

  PlaceLatLng({required this.lat, required this.lng});

  factory PlaceLatLng.fromJson(Map<String, dynamic> parsedJson) {
    return PlaceLatLng(
      lat: parsedJson['lat'] as double,
      lng: parsedJson['lng'] as double,
    );
  }
}
