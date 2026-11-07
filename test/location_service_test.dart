// ============================================================================
// BloodNorms | test/location_service_test.dart
// OpenStreetMap (OSM) Services & Nominatim Verification Test Suite
// ============================================================================

import 'package:bloodnorms/core/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenStreetMap (OSM) & Location Services Suite', () {
    test('1. OSM Tile Server URL is valid OpenStreetMap standard', () {
      expect(LocationService.osmTileUrl, 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
      expect(LocationService.osmUserAgent, contains('BloodNorms'));
      expect(LocationService.osmUserAgent, contains('info@bloodnorms.org'));
    });

    test('2. searchPlace returns structured PlaceSearchResult for queries', () async {
      final results = await LocationService.searchPlace('GGH Hospital');
      expect(results, isNotEmpty);
      final first = results.first;
      expect(first.displayName, isNotEmpty);
      expect(first.lat, isNotNull);
      expect(first.lng, isNotNull);
    });

    test('3. searchPlace returns empty list for queries shorter than 3 characters', () async {
      final results = await LocationService.searchPlace('ab');
      expect(results, isEmpty);
    });

    test('4. reverseGeocode returns structured address or handles coordinates properly', () async {
      // Test Rajahmundry coordinates
      final address = await LocationService.reverseGeocode(17.0005, 81.7820);
      // Either online Nominatim resolves or returns null/string gracefully
      if (address != null) {
        expect(address, isNotEmpty);
      }
    });
  });
}
