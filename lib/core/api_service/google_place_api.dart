import 'dart:convert';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:place_search_and_map/core/data_models/lat_lng.dart';
import 'package:place_search_and_map/core/data_models/suggestion.dart';

import '../api_key.dart';

class PlaceGoogleApiService {
  static const baseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  Future<List<Suggestion>> fetchSuggestions({
    required String input,
    required String lang,
    required String sessionToken,
    String country = 'ca',
  }) async {
    final uri = '$baseUrl?input=$input&types=address&language=$lang'
        '&components=country:$country&key=${APIKeys.placeAPIKey}'
        '&sessiontoken=$sessionToken';

    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final dynamic convertedJson = jsonDecode(response.body);

      if (convertedJson['status'] == 'OK') {
        final predictionsJson = convertedJson['predictions'] as List;

        return predictionsJson
            .map((dynamic p) => Suggestion(
                placeId: p['place_id'] as String,
                description: p['description'] as String))
            .toList();
        // return predictionsJson
        //     .map((dynamic place) =>
        //         Suggestion.fromMap(place as Map<String, dynamic>))
        //     .toList();
      } else if (convertedJson['status'] == 'ZERO_RESULTS') {
        return [];
      } else {
        throw Exception(convertedJson['error_message']);
      }
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<LatLng?> geocodingSearch(String value) async {
    final googleGeocoding = GoogleGeocoding(APIKeys.placeAPIKey);
    final List<GeocodingResult> geocodingResults;

    final response = await googleGeocoding.geocoding.get(value, []);

    if (response != null && response.results != null) {
      geocodingResults = response.results!;
      if (geocodingResults.isNotEmpty) {
        final lat = geocodingResults[0].geometry?.location?.lat;
        final lng = geocodingResults[0].geometry?.location?.lng;
        if (lat != null && lng != null) {
          return LatLng(lat: lat, lng: lng);
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

  Future<bool> saveSelectedAddress({
    required String placeId,
    required double latitude,
    required double longitude,
    required String sessionToken,
    String suite = "",
    String note = "",
  }) async {
    //temporary variable to pass to backend,these could be null
    String streetNumber = '';
    String street = '';
    String city = '';
    String province = '';
    String country = '';
    String zipCode = '';

    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId'
        '&fields=address_component&key=${APIKeys.placeAPIKey}&sessiontoken=$sessionToken';

    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final dynamic result = json.decode(response.body);

      // if (result['status'] == 'OK') {
      //   final components = result['result']['address_components'];
      //   components.map((c) {
      //     final type = c['types'] as List<dynamic>;
      //     if (type.contains('street_number')) {
      //       streetNumber = c['long_name'] as String;
      //     }
      //     if (type.contains('route')) {
      //       street = c['long_name'] as String;
      //     }
      //     if (type.contains('locality')) {
      //       city = c['long_name'] as String;
      //     }
      //     if (type.contains('administrative_area_level_1')) {
      //       province = c['long_name'] as String;
      //     }
      //     if (type.contains('country')) {
      //       country = c['long_name'] as String;
      //     }
      //     if (type.contains('postal_code')) {
      //       zipCode = c['long_name'] as String;
      //     }
      //   }).toList();
      //
      //   final String address;
      //   if (streetNumber == '') {
      //     address = street;
      //   } else {
      //     address = '$streetNumber $street';
      //   }
      //
      //   //pass all values to backend
      //   final isUserAuthorized = locator<AuthBase>().isAuthenticated;
      //   bool success;
      //   if (isUserAuthorized) {
      //     success = await locator
      //         .get<AddressAPIService>(instanceName: "Authorized")
      //         .addAddress(
      //             address: address,
      //             city: city,
      //             province: province,
      //             country: country,
      //             postalCode: zipCode,
      //             suite: suite,
      //             note: note);
      //   } else {
      //     success = await locator
      //         .get<AddressAPIService>(instanceName: "Anonymous")
      //         .addAddress(
      //             address: address,
      //             city: city,
      //             province: province,
      //             country: country,
      //             postalCode: zipCode,
      //             suite: suite,
      //             note: note);
      //   }
      //
      //   if (success) {
      //     return true;
      //   }
      // }
      return false;
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
