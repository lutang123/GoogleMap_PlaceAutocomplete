import 'dart:convert';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:place_search_and_map/core/models/address.dart';
import 'package:place_search_and_map/core/models/lat_lng.dart';
import 'package:place_search_and_map/core/models/suggestion.dart';

import '../api_keys.dart';

class PlaceApiService {
  static Future<List<Suggestion>> fetchSuggestions(
      {required String input,
      required String lang,
      required String sessionToken,
      //up to 5 countries
      String country1 = 'ca',
      String country2 = 'us'}) async {
    const baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    final uri = '$baseUrl?input=$input&types=address&language=$lang'
        '&components=country:$country1|country:$country2&key=${APIKeys.placeAPIKey}'
        '&sessiontoken=$sessionToken';

    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final dynamic parsedJson = jsonDecode(response.body);
      if (parsedJson['status'] == 'OK') {
        final predictionsJson = parsedJson['predictions'] as List;
        return predictionsJson
            .map((dynamic place) =>
                Suggestion.fromMap(place as Map<String, dynamic>))
            .toList();
      } else if (parsedJson['status'] == 'ZERO_RESULTS') {
        return [];
      } else {
        throw Exception(parsedJson['error_message']);
      }
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  static Future<PlaceLatLng?> geocoding(String value) async {
    final googleGeocoding = GoogleGeocoding(APIKeys.placeAPIKey);
    final List<GeocodingResult> geocodingResults;

    final response = await googleGeocoding.geocoding.get(value, []);

    if (response != null && response.results != null) {
      geocodingResults = response.results!;
      if (geocodingResults.isNotEmpty) {
        final lat = geocodingResults[0].geometry?.location?.lat;
        final lng = geocodingResults[0].geometry?.location?.lng;
        if (lat != null && lng != null) {
          return PlaceLatLng(lat: lat, lng: lng);
        }
      }
    }
  }

  Future<String> reverseGeocoding(
      {required double lat, required double lng}) async {
    final googleGeocoding = GoogleGeocoding(APIKeys.placeAPIKey);
    final response =
        await googleGeocoding.geocoding.getReverse(LatLon(lat, lng));

    if (response != null && response.results != null) {
      final geocodingResponse = response.results;
      if (geocodingResponse != null) {
        if (geocodingResponse.isNotEmpty) {
          final address = geocodingResponse[0].formattedAddress;
          if (address != null) {
            return address;
          }
        }
      }
    }
    return '';
  }

  Future<Address?> getAddress({
    required String placeId,
    required String sessionToken,
  }) async {
    const baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';

    final uri = '$baseUrl?place_id=$placeId'
        '&fields=address_component&key=${APIKeys.placeAPIKey}&sessiontoken=$sessionToken';

    final response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      final dynamic parsedJson = jsonDecode(response.body);
      if (parsedJson['status'] == 'OK') {
        final dynamic result = parsedJson['result'];
        return Address.fromMap(result as Map<String, dynamic>);
      }
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
