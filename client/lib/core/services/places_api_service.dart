import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:client/features/map/models/place_data.dart';

class PlacesApiService {
  static const String _apiBaseUrl = kDebugMode ? "https://10.0.2.2:7234/api": "https://192.168.1.2:7234/api";
  static const Duration _apiTimeout = Duration(seconds: 5);

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
              "radius": 2000,
            }),
          ).timeout(_apiTimeout);
      if (response.statusCode == 200) {
        return PlaceResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      return _loadPlacesFromAsset();
    }
  }

  Future<PlaceResponse> _loadPlacesFromAsset() async {
    final jsonString = await rootBundle.loadString("assets/data/places.json");
    return PlaceResponse.fromJson(jsonDecode(jsonString));
  }
}
