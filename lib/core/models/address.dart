class Address {
  final double latitude;
  final double longitude;
  final String streetNumber;
  final String street;
  final String suite;
  final String city;
  final String province;
  final String country;
  final String postalCode;
  final String note;

  const Address({
    required this.latitude,
    required this.longitude,
    required this.streetNumber,
    required this.street,
    this.suite = '',
    required this.city,
    required this.province,
    required this.country,
    required this.postalCode,
    this.note = '',
  });

  factory Address.fromMap(Map<String, dynamic> parsedJson) {
    //temporary variables
    String? _streetNumber;
    String? _street;
    String? _city;
    String? _province;
    String? _country;
    String? _postalCode;

    final components = parsedJson['result']['address_components'] as List;
    components.map((dynamic c) {
      final type = c['types'] as List;
      if (type.contains('street_number')) {
        _streetNumber = c['long_name'] as String;
      }
      if (type.contains('route')) {
        _street = c['long_name'] as String;
      }
      if (type.contains('locality')) {
        _city = c['long_name'] as String;
      }
      if (type.contains('administrative_area_level_1')) {
        _province = c['long_name'] as String;
      }
      if (type.contains('country')) {
        _country = c['long_name'] as String;
      }
      if (type.contains('postal_code')) {
        _postalCode = c['long_name'] as String;
      }
    });

    return Address(
      latitude: parsedJson['geometry']['location']['lat'] as double,
      longitude: parsedJson['geometry']['location']['lng'] as double,
      streetNumber: _streetNumber ?? '',
      street: _street ?? '',
      city: _city ?? '',
      province: _province ?? '',
      country: _country ?? '',
      postalCode: _postalCode ?? '',
    );
  }
}
