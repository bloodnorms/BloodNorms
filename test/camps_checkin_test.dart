// ============================================================================
// BloodNorms | camps_checkin_test.dart
// Unit tests for Stage 4: Camp Check-in & Attendance Counters
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/shared/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Stage 4: Camp QR Check-in & Live Drives', () {
    test('CampModel parses new attendee counters with backward compatibility', () {
      // Legacy JSON without new columns
      final legacyJson = {
        'id': 'camp-001',
        'bank_id': 'bank-001',
        'title': 'Community Blood Drive',
        'venue': 'Town Hall',
        'area': 'Danavaipeta',
        'starts_at': '2026-11-10T09:00:00Z',
        'ends_at': '2026-11-10T17:00:00Z',
        'capacity': 150,
        'status': 'published',
        'lat': 17.0005,
        'lng': 81.7800,
      };

      final campFromLegacy = CampModel.fromJson(legacyJson);
      expect(campFromLegacy.id, 'camp-001');
      expect(campFromLegacy.attendeesCheckedIn, 0); // Default fallback
      expect(campFromLegacy.unitsCollected, 0);    // Default fallback

      // Modern JSON with live attendee and unit counters
      final modernJson = Map<String, dynamic>.from(legacyJson);
      modernJson['attendees_checked_in'] = 42;
      modernJson['units_collected'] = 38;

      final campFromModern = CampModel.fromJson(modernJson);
      expect(campFromModern.attendeesCheckedIn, 42);
      expect(campFromModern.unitsCollected, 38);

      // JSON serialization includes new counters
      final serialized = campFromModern.toJson();
      expect(serialized['attendees_checked_in'], 42);
      expect(serialized['units_collected'], 38);
    });

    test('checkInCampAttendee registers check-in and returns positive verification', () async {
      final service = SupabaseService();
      final res = await service.checkInCampAttendee(
        campId: 'camp-test-99',
        phone: '+919848012345',
        units: 2,
      );

      expect(res['ok'], isTrue);
      expect(res['total_donations'], 2);
    });
  });
}
