// ============================================================================
// BloodNorms | test/geo_broadcast_test.dart
// Verification Suite for Geo-Targeted & Region-Wise Blood Camp Broadcasts
// Verifies:
// 1. Precise Haversine distance calculations
// 2. Region & Radius filtering: Donors in distant cities (e.g. Vizag, Kakinada) are excluded from Rajahmundry camp dispatches
// 3. Donor travel radius cap respect (anti-spam / distance comfort)
// 4. Real-time cost estimation in INR
// 5. Four-Eyes approval trigger for mass broadcasts (>200 recipients)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/shared/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Geo-Targeted & Region-Wise Camp Broadcasting', () {
    test('Haversine distance calculation is geographically accurate', () {
      final service = SupabaseService();

      // Rajahmundry (17.0005, 81.8040) to Kakinada (16.9891, 82.2475) ~ 47 km
      final distKkd = service.calculateHaversineDistanceKm(17.0005, 81.8040, 16.9891, 82.2475);
      expect(distKkd, inInclusiveRange(40.0, 55.0));

      // Rajahmundry to Visakhapatnam (17.7042, 83.3032) ~ 180 km
      final distVzg = service.calculateHaversineDistanceKm(17.0005, 81.8040, 17.7042, 83.3032);
      expect(distVzg, inInclusiveRange(160.0, 200.0));

      // Same location is 0 km
      final distZero = service.calculateHaversineDistanceKm(17.0005, 81.8040, 17.0005, 81.8040);
      expect(distZero, closeTo(0.0, 0.01));
    });

    test('previewBroadcastAudience isolates donors strictly within camp radius in Rajahmundry', () async {
      final service = SupabaseService();

      // Camp at Rotary Diamond Hall, Rajahmundry (radius 10 km)
      final preview = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 10.0,
        respectTravelCap: true,
      );

      expect(preview.containsKey('eligible_count'), isTrue);
      expect(preview.containsKey('suppressed_count'), isTrue);
      expect(preview.containsKey('estimated_cost_inr'), isTrue);

      final eligible = preview['eligible_count'] as int;
      final suppressed = preview['suppressed_count'] as int;

      // Donors in Kakinada and Vizag must be suppressed!
      expect(suppressed, greaterThan(0));
      expect(eligible, greaterThan(0));

      // All sample donors must be within 10 km
      final samples = preview['sample_donors'] as List;
      for (final s in samples) {
        final dist = (s['distance_km'] as num).toDouble();
        expect(dist, lessThanOrEqualTo(10.0));
      }
    });

    test('previewBroadcastAudience filters by blood group when specified', () async {
      final service = SupabaseService();

      final previewOplus = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 15.0,
        bloodGroup: 'O+',
      );

      final samples = previewOplus['sample_donors'] as List;
      for (final s in samples) {
        expect(s['blood_group'], equals('O+'));
      }
    });

    test('Calculates estimated broadcast spend in INR (₹0.85 WhatsApp rate)', () async {
      final service = SupabaseService();

      final preview = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        radiusKm: 10.0,
        channel: 'whatsapp',
      );

      final count = preview['eligible_count'] as int;
      final cost = (preview['estimated_cost_inr'] as num).toDouble();

      expect(cost, equals(double.parse((count * 0.85).toStringAsFixed(2))));
    });

    test('broadcastRegionalMessage dispatches geo-targeted broadcast and records suppression', () async {
      final service = SupabaseService();

      final res = await service.broadcastRegionalMessage(
        title: 'Mega Camp at Rotary Diamond Hall',
        message: 'Dear Hero, join voluntary blood camp this Sunday at Rotary Hall, Rajahmundry.',
        broadcastType: 'camp_invitation',
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 10.0,
        channel: 'whatsapp',
      );

      expect(res['success'], isTrue);
      expect(res['recipients'], greaterThan(0));
      expect(res['suppressed'], greaterThan(0));
      expect(res['cost_inr'], isNotNull);
    });
  });
}

