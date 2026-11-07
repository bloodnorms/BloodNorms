// ============================================================================
// BloodNorms | test/admin_am5_am11_test.dart
// Milestones AM5 through AM11 Verification Suite:
// - AM5: Operations Desks (Requester profiles, abuse prevention)
// - AM6: People & Places (Verified hospitals with coordinates, banks)
// - AM7: Messaging & Telephony
// - AM8: AI Voice Studio (Prompt versioning, 60-dialogue eval runner)
// - AM10: Safety & DPDP (Incidents desk, DPDP Act 2023 compliance)
// - AM11: Growth & Partners (Community alliances: Red Cross, Rotary, Lions, NSS)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Milestones AM5..AM11 Operations & Features Suite', () {
    test('AM5: Requester profiles registry provides abuse indicators and block toggle', () async {
      final profiles = await SupabaseService().getRequesterProfiles();
      expect(profiles, isNotEmpty);
      final p = profiles.first;
      expect(p.containsKey('phone'), isTrue);
      expect(p.containsKey('abuse_score'), isTrue);

      final ok = await SupabaseService().setRequesterBlockStatus(
        phone: p['phone'] as String,
        isBlocked: true,
        reason: 'Repeated frivolous emergency alerts',
      );
      expect(ok, isTrue);
    });

    test('AM6: Verified hospitals registry returns GPS coordinates and blood bank presence', () async {
      final hospitals = await SupabaseService().getHospitals();
      expect(hospitals, isNotEmpty);
      final h = hospitals.first;
      expect(h.containsKey('name'), isTrue);
      expect(h.containsKey('latitude'), isTrue);
      expect(h.containsKey('longitude'), isTrue);
      expect(h['is_verified'], isTrue);
      expect(h['latitude'] as num, inInclusiveRange(10.0, 30.0));
      expect(h['longitude'] as num, inInclusiveRange(70.0, 90.0));
    });

    test('AM8: AI Voice Studio prompt versioning and 60-dialogue evaluation runner', () async {
      final versions = await SupabaseService().getAIPromptVersions();
      expect(versions, isNotEmpty);
      final active = versions.firstWhere((v) => v['is_active'] == true);
      expect(active['version_tag'], contains('v1.0.0'));
      expect(active['safety_guidelines'], isNotEmpty);

      // Run 60-dialogue synthetic evaluation
      final evalRun = await SupabaseService().runAIEvaluationSuite(
        promptVersionId: active['id']?.toString() ?? 'prompt-v1',
      );
      expect(evalRun['total_test_dialogues'], equals(60));
      expect(evalRun['passed_count'], equals(60));
      expect(evalRun['status'], equals('passed'));
      expect(evalRun['safety_score_percent'], equals(100.0));
    });

    test('AM10: Safety incidents desk tracking P1..P4 severity', () async {
      final incidents = await SupabaseService().getSafetyIncidents();
      expect(incidents, isNotEmpty);
      final inc = incidents.first;
      expect(inc.containsKey('title'), isTrue);
      expect(inc.containsKey('severity'), isTrue);
      expect(['P1_critical', 'P2_major', 'P3_moderate', 'P4_minor'], contains(inc['severity']));
    });

    test('AM10: DPDP Act 2023 compliance registry records masked phone and status', () async {
      final reqs = await SupabaseService().getDPDPRequests();
      expect(reqs, isNotEmpty);
      final r = reqs.first;
      expect(r['phone_masked'], contains('***'));
      expect(['erasure', 'export', 'rectification'], contains(r['request_type']));
    });

    test('AM11: Registered community partners include Red Cross, Rotary, and Lions', () async {
      final partners = await SupabaseService().getCommunityPartners();
      expect(partners, isNotEmpty);
      final names = partners.map((p) => p['name'].toString()).toList();
      expect(names.any((n) => n.contains('Red Cross')), isTrue);
      expect(names.any((n) => n.contains('Rotary')), isTrue);
      expect(names.any((n) => n.contains('Lions')), isTrue);
    });
  });
}

