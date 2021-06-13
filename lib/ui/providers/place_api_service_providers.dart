import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_search_and_map/core/api_service/google_place_api.dart';

final placeApiServiceProvider =
    Provider<PlaceApiService>((ref) => PlaceApiService());
