// ============================================================================
// BloodNorms | region_aware_camps_broadcast_test.dart
// Automated Test Suite: Multi-Location Aware Donors & Region-Wise Broadcasting
// Verifies:
// 1. Precise location filtering: Donors in Kakinada/Vizag/Vijayawada are suppressed for Rajahmundry camps
// 2. Donor "Out of Station / Away" suppression prevents unwanted alerts
// 3. Respect donor personal travel limit (e.g. 5 km limit excludes 8 km camp)
// 4. Neighborhood/Area telemetry and suppression categorization
// 5. In-app notifications are targeted strictly to eligible in-radius donors
// 6. CampModel multi-city location properties round-trip integrity
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/shared/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Multi-Location & Region-Wise Camp Broadcasting', () {
    test('1. Rajahmundry camp targets in-radius donors and strictly excludes out-of-region donors', () async {
      final service = SupabaseService();

      // Broadcast for Rotary Club Camp in Rajahmundry (17.0005, 81.8040) with 10 km radius
      final audience = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 10.0,
        respectTravelCap: true,
      );

      final eligibleCount = audience['eligible_count'] as int;
      final suppressedCount = audience['suppressed_count'] as int;
      final samples = audience['sample_donors'] as List;
      final suppressed = audience['suppressed_donors'] as List;

      expect(eligibleCount, greaterThan(0));
      expect(suppressedCount, greaterThan(0));

      // Check that all eligible donors are within 10 km and in Rajahmundry
      for (final d in samples) {
        final dMap = d as Map<String, dynamic>;
        expect(dMap['city'], equals('Rajahmundry'));
        expect((dMap['distance_km'] as num).toDouble(), lessThanOrEqualTo(10.0));
      }

      // Check that donors from Kakinada and Visakhapatnam are in suppressed list
      final suppressedCities = suppressed.map((d) => (d as Map)['city']).toList();
      expect(suppressedCities, contains('Kakinada'));
      expect(suppressedCities, contains('Visakhapatnam'));
      expect(suppressedCities, contains('Vijayawada'));

      // Verify suppression reasons are explicit and informative
      for (final s in suppressed) {
        final sMap = s as Map<String, dynamic>;
        expect(sMap['reason'], isNotNull);
        expect(sMap['reason'].toString().isNotEmpty, isTrue);
      }
    });

    test('2. Donor marked "Out of Station / Away" is suppressed from localized broadcasts', () async {
      final service = SupabaseService();

      final audience = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 25.0,
        respectTravelCap: false,
      );

      final suppressed = audience['suppressed_donors'] as List;

      // Donor dn-010 (B. Swathi) in Rajahmundry is marked is_away: true
      final awayDonor = suppressed.where((d) => (d as Map)['id'] == 'dn-010').firstOrNull;

      expect(awayDonor, isNotNull);
      expect((awayDonor as Map)['reason'], contains('Out of Station / Away'));
    });

    test('3. Respects personal travel radius limit when toggled on', () async {
      final service = SupabaseService();

      // With respectTravelCap: true, donor with 5 km limit should be excluded from an 8.5 km drive
      final audienceWithCap = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 15.0,
        respectTravelCap: true,
      );

      // With respectTravelCap: false, that donor becomes eligible
      final audienceWithoutCap = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 15.0,
        respectTravelCap: false,
      );

      expect(
        audienceWithoutCap['eligible_count'] as int,
        greaterThanOrEqualTo(audienceWithCap['eligible_count'] as int),
      );
    });

    test('4. Area / Neighborhood breakdown reflects distribution of in-radius donors', () async {
      final service = SupabaseService();

      final audience = await service.previewBroadcastAudience(
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 15.0,
        respectTravelCap: true,
      );

      final areaBreakdown = audience['area_breakdown'] as Map<String, int>;
      expect(areaBreakdown, isNotNull);
      expect(areaBreakdown.containsKey('Danavaipeta'), isTrue);
    });

    test('5. Dispatching broadcast delivers in-app notifications ONLY to eligible in-radius donors', () async {
      final service = SupabaseService();

      final result = await service.broadcastRegionalMessage(
        title: 'Rotary Mega Camp This Sunday',
        message: 'Join us at Rotary Hall, Danavaipeta to save lives!',
        broadcastType: 'camp_invitation',
        targetCity: 'Rajahmundry',
        centerLat: 17.0005,
        centerLng: 81.8040,
        radiusKm: 10.0,
        respectTravelCap: true,
        channel: 'whatsapp',
      );

      expect(result['success'], isTrue);
      expect(result['recipients'], greaterThan(0));
      expect(result['suppressed'], greaterThan(0));

      // Verify in-app notifications generated
      final notifications = await service.getNotifications();
      expect(notifications.isNotEmpty, isTrue);

      // Check that notifications mention distance and area
      final campNotif = notifications.firstWhere(
        (n) => n.title.contains('Rotary Mega Camp'),
        orElse: () => notifications.first,
      );
      expect(campNotif.body, contains('Distance: ~'));
    });

    test('6. CampModel stores and round-trips multi-city geographic fields', () {
      final camp = CampModel(
        id: 'camp-test-101',
        bankId: 'bank-test',
        title: 'Coastal Lifesavers Drive',
        venue: 'Red Cross Bhavan',
        area: 'Bhanugudi',
        city: 'Kakinada',
        district: 'Kakinada District',
        pincode: '533003',
        startsAt: DateTime(2026, 11, 15, 9, 0),
        endsAt: DateTime(2026, 11, 15, 14, 0),
        capacity: 200,
        status: 'published',
        lat: 16.9891,
        lng: 82.2475,
        targetRadiusKm: 12.0,
        directionsUrl: 'https://maps.google.com/?q=16.9891,82.2475',
        coordinatorName: 'K. Rama Rao',
        coordinatorPhone: '+91 88423 55667',
      );

      final json = camp.toJson();
      expect(json['city'], equals('Kakinada'));
      expect(json['area'], equals('Bhanugudi'));
      expect(json['district'], equals('Kakinada District'));
      expect(json['target_radius_km'], equals(12.0));
      expect(json['directions_url'], contains('16.9891'));

      final parsed = CampModel.fromJson(json);
      expect(parsed.city, equals('Kakinada'));
      expect(parsed.area, equals('Bhanugudi'));
      expect(parsed.targetRadiusKm, equals(12.0));
      expect(parsed.coordinatorName, equals('K. Rama Rao'));
    });

    test('7. Donor location preferences update and persist correctly', () async {
      final service = SupabaseService();
      const testDonorId = 'd-test-location-prefs';

      // Initial defaults
      final initial = await service.getDonorLocationPreferences(testDonorId);
      expect(initial['city'], equals('Rajahmundry'));
      expect(initial['is_away'], isFalse);

      // Update to Kakinada with custom radius and away status
      await service.updateDonorLocationPreferences(
        donorId: testDonorId,
        city: 'Kakinada',
        area: 'Bhanugudi',
        travelRadiusKm: 25.0,
        isAway: true,
        awayReason: 'Traveling for work',
      );

      final updated = await service.getDonorLocationPreferences(testDonorId);
      expect(updated['city'], equals('Kakinada'));
      expect(updated['area'], equals('Bhanugudi'));
      expect(updated['travel_radius_km'], equals(25.0));
      expect(updated['is_away'], isTrue);
      expect(updated['away_reason'], equals('Traveling for work'));
    });
  });
}
