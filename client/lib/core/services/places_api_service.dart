import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:client/features/map/models/place_data.dart';

class PlacesApiService {
  // https://10.0.2.2:7234/api emülatör url
  static const String _apiBaseUrl = kDebugMode ? "https://10.0.2.2:7234/api" : "https://192.168.1.2:7234/api";
  static const Duration _apiTimeout = Duration(seconds: 5);
  static final String _googlePlacesApiKey = dotenv.env['GOOGLE_PLACES_API_KEY']!;

  Future<PlaceResponse> fetchPlaces(LatLng location) async {
    try {
      final uri = Uri.parse("$_apiBaseUrl/getPlaces");
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "latitude": location.latitude,
              "longitude": location.longitude,
              "radius": 1500 // 1.5km çap
            }),
          ).timeout(_apiTimeout);
      if (response.statusCode == 200) {
        return PlaceResponse.fromJson(jsonDecode(response.body));
      } else {
        return _fetchPlacesFromGoogle(location);
      }
    } catch (e) {
      return _fetchPlacesFromGoogle(location);
    }
  }

  Future<PlaceResponse> _fetchPlacesFromGoogle(LatLng location) async {
    final String baseUrl = "https://places.googleapis.com/v1/places:searchNearby";
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Goog-FieldMask": (
          "places.id,places.displayName,places.location,places.rating,"
          "places.userRatingCount,places.formattedAddress,"
          "places.primaryTypeDisplayName,places.reviews,"
          "places.iconBackgroundColor,places.iconMaskBaseUri"
      ),
      "X-Goog-Api-Key": _googlePlacesApiKey,
    };

    final Map<String, dynamic> payload = {
      "maxResultCount": 20,
      "locationRestriction": {
        "circle": {
          "center": {"latitude": location.latitude, "longitude": location.longitude},
          "radius": 1500, // 1.5km çap
        }
      },
      "languageCode": "tr",
    };

    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.post(uri, headers: headers, body: jsonEncode(payload)).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> placesJson = responseBody['places'] ?? [];
        final List<Place> places = placesJson.map((json) => Place.fromJson(json)).toList();
        return PlaceResponse(places: places);
      } else {
        throw Exception("Google Places API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Yerel veya Google API'den veri alınamadı. Hata: $e");
    }
  }

  // @Deprecated("Kullanımda kaldırıldı artık Google Maps API'ye request yapılıyor.")
  // Future<PlaceResponse> _loadPlacesFromAsset() async {
  //   final jsonString = await rootBundle.loadString("assets/data/places.json");
  //   return PlaceResponse.fromJson(jsonDecode(jsonString));
  // }
}
