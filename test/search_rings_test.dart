// ============================================================================
// BloodNorms | test/search_rings_test.dart
// Unit tests for search rings, gates, and wave durations per BR-06..08
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bloodnorms/core/constants/rings.dart';

void main() {
  group('Search Rings & Gates Tests (BR-06, BR-07, BR-08)', () {
    test('Verify rings list matches BR-06 specification', () {
      expect(SearchRings.ringsKm, [
        0.5, 1.0, 2.0, 3.0, 5.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 70.0, 90.0, 100.0,
      ]);
    });

    test('Verify gates at 70, 90, 100 km per BR-07', () {
      expect(SearchRings.isGateRing(70.0), isTrue);
      expect(SearchRings.isGateRing(90.0), isTrue);
      expect(SearchRings.isGateRing(100.0), isTrue);

      expect(SearchRings.isGateRing(50.0), isFalse);
      expect(SearchRings.isGateRing(30.0), isFalse);
    });

    test('Verify wave durations per BR-08', () {
      expect(SearchRings.waveDuration('now'), const Duration(minutes: 3));
      expect(SearchRings.waveDuration('within_6h'), const Duration(minutes: 8));
      expect(SearchRings.waveDuration('within_24h'), const Duration(minutes: 20));
      expect(SearchRings.waveDuration('planned'), const Duration(minutes: 60));
    });

    test('Verify privacy distance band masking', () {
      expect(SearchRings.formatDistanceBand(0.7), '< 1 km');
      expect(SearchRings.formatDistanceBand(2.5), '1–3 km');
      expect(SearchRings.formatDistanceBand(4.0), '3–5 km');
      expect(SearchRings.formatDistanceBand(8.0), '5–10 km');
      expect(SearchRings.formatDistanceBand(18.0), '10–25 km');
      expect(SearchRings.formatDistanceBand(42.0), '25–50 km');
      expect(SearchRings.formatDistanceBand(75.0), '50–100 km');
    });
  });
}

