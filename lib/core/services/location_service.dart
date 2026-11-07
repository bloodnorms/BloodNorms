// ============================================================================
// BloodNorms | location_service.dart
// 100% Free Open-Source OpenStreetMap (OSM) Services:
// - Device GPS location via geolocator
// - OpenStreetMap Nominatim search & forward geocoding (Zero Google Billing)
// - OpenStreetMap Nominatim reverse geocoding (Coordinates -> Real Locality)
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
  final String? city;
  final String? locality;

  PlaceSearchResult({
    required this.displayName,
    required this.lat,
    required this.lng,
    this.pincode,
    this.city,
    this.locality,
  });
}

class LocationService {
  /// OpenStreetMap Tile Layer template (100% free, zero API key)
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'BloodNorms-Emergency-Finder/1.0 (info@bloodnorms.org)';

  /// Get current GPS coordinates from the device
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

  /// Search OpenStreetMap Nominatim for places, hospitals, or pincodes (Free, no Google billing)
  static Future<List<PlaceSearchResult>> searchPlace(String query) async {
    if (query.trim().length < 3) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&countrycodes=in&limit=5',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': osmUserAgent,
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) {
            final addr = item['address'] as Map<String, dynamic>?;
            final postcode = addr?['postcode']?.toString();
            final city = addr?['city'] ?? addr?['town'] ?? addr?['district'] ?? 'Rajahmundry';
            final locality = addr?['neighbourhood'] ?? addr?['suburb'] ?? addr?['residential'];

            return PlaceSearchResult(
              displayName: item['display_name'] ?? query,
              lat: double.tryParse(item['lat']?.toString() ?? '') ?? AppConstants.defaultLat,
              lng: double.tryParse(item['lon']?.toString() ?? '') ?? AppConstants.defaultLng,
              pincode: postcode,
              city: city?.toString(),
              locality: locality?.toString(),
            );
          }).toList();
        }
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
        city: 'Rajahmundry',
        locality: query,
      ),
    ];
  }

  /// Reverse geocode coordinates to a clean readable locality using OpenStreetMap Nominatim
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': osmUserAgent,
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final addr = data['address'] as Map<String, dynamic>?;

        if (addr != null) {
          final locality = addr['neighbourhood'] ??
              addr['suburb'] ??
              addr['residential'] ??
              addr['road'] ??
              addr['village'];

          final city = addr['city'] ?? addr['town'] ?? addr['district'] ?? addr['state_district'];
          final state = addr['state'];
          final postcode = addr['postcode'];

          final parts = <String>[];
          if (locality != null && locality.toString().isNotEmpty) parts.add(locality.toString());
          if (city != null && city.toString().isNotEmpty) parts.add(city.toString());
          if (state != null && state.toString().isNotEmpty) parts.add(state.toString());

          String formatted = parts.join(', ');
          if (postcode != null && postcode.toString().isNotEmpty) {
            formatted += ' - $postcode';
          }

          if (formatted.isNotEmpty) return formatted;
        }

        final displayName = data['display_name']?.toString();
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }
    } catch (e) {
      debugPrint('Nominatim reverse geocode error: $e');
    }

    return null;
  }
}
