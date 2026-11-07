// ============================================================================
// BloodNorms | location_service.dart
// GPS device location + OpenStreetMap Nominatim place search (Free, no Google billing)
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class PlaceSearchResult {
  final String displayName;
  final double lat;
  final double lng;
  final String? pincode;

  PlaceSearchResult({
    required this.displayName,
    required this.lat,
    required this.lng,
    this.pincode,
  });
}

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return null;
    }
  }

  // Search OpenStreetMap Nominatim proxy
  static Future<List<PlaceSearchResult>> searchPlace(String query) async {
    if (query.trim().length < 3) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&countrycodes=in&limit=5',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'BloodNorms-Emergency-Finder/1.0 (info@arkiolabs.com)',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return PlaceSearchResult(
            displayName: item['display_name'] ?? '',
            lat: double.tryParse(item['lat']?.toString() ?? '') ?? AppConstants.defaultLat,
            lng: double.tryParse(item['lon']?.toString() ?? '') ?? AppConstants.defaultLng,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Nominatim geocode error: $e');
    }

    // Default fallback in pilot city
    return [
      PlaceSearchResult(
        displayName: '$query, Rajahmundry, East Godavari, Andhra Pradesh',
        lat: AppConstants.defaultLat,
        lng: AppConstants.defaultLng,
        pincode: '533101',
      ),
    ];
  }
}

