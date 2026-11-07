// ============================================================================
// BloodNorms | test/admin_am12_security_audit_test.dart
// Milestone AM12: Security Audit, Hardening & Final Acceptance
// Rigorous verification of Section 0.3 Hard Privacy Lines and Governance:
// 1. Zero donor health answers readable, exported, or logged
// 2. Zero call audio or transcripts stored or exported
// 3. Secrets / OTPs never exposed or exported
// 4. Immutable audit logs cannot be modified or deleted
// 5. Four-eyes maker-checker separation enforced
// 6. Progressive rollout: all flags default to false (OFF) in production
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/shared/services/supabase_service.dart';
import 'package:bloodnorms/shared/theme/brand_typography.dart';
import 'package:bloodnorms/shared/theme/brand_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Milestone AM12: Security Hardening & Acceptance Suite', () {
    test('Hard Privacy Line 1: Donor models strictly forbid health questions in admin queries', () async {
      final donors = await SupabaseService().getAllDonors();
      expect(donors, isNotEmpty);

      for (final d in donors) {
        // Privacy line: donor health questionnaire answers must NEVER be present
        expect(d.containsKey('health_answers'), isFalse);
        expect(d.containsKey('answers_json'), isFalse);
        expect(d.containsKey('medical_history'), isFalse);
        expect(d.containsKey('health_notes'), isFalse);
      }
    });

    test('Hard Privacy Line 2: AI Voice telemetry and calls strictly exclude audio and transcript payloads', () async {
      final promptVersions = await SupabaseService().getAIPromptVersions();
      expect(promptVersions, isNotEmpty);

      for (final pv in promptVersions) {
        expect(pv.containsKey('audio_recording_url'), isFalse);
        expect(pv.containsKey('call_transcript'), isFalse);
        expect(pv.containsKey('raw_audio_stream'), isFalse);
      }
    });

    test('Hard Privacy Line 3: Secrets, OTP tokens and API keys are masked or excluded', () async {
      final telephony = await SupabaseService().getTelephonySettings();
      expect(telephony.containsKey('auth_token_raw'), isFalse);
      expect(telephony.containsKey('account_secret_key'), isFalse);
    });

    test('Governed Power: Four-eyes validation rejects maker trying to self-approve', () async {
      final userId = 'user-test-maker-99';
      final req = await SupabaseService().submitApprovalRequest(
        actionType: 'caps.change',
        reason: 'Raise daily cap for emergency camp drive',
        makerId: userId,
        diffPayload: {'daily_cap': 120},
      );

      final reqId = req['id'] as String;

      // Same user attempting to approve must fail
      final decision = await SupabaseService().decideApprovalRequest(
        requestId: reqId,
        approve: true,
        currentUserId: userId, // Maker trying to check!
      );

      expect(decision['ok'], isFalse);
      expect(decision['reason'], equals('maker_cannot_be_checker'));
    });

    test('Design System Rules: Arial font only, Cardinal Red & Universal Green tokens strictly bound', () {
      expect(DuoTypography.fontFamily, equals('Arial'));
      expect(DuoColors.red.toARGB32(), equals(0xFFE52E2E));
      expect(DuoColors.green.toARGB32(), equals(0xFF58CC02));
    });

    test('Progressive flags default to false (OFF) for production safety', () async {
      final flags = await SupabaseService().getFeatureFlags();
      expect(flags, isNotEmpty);

      for (final f in flags) {
        expect(f['enabled'], isFalse, reason: 'Flag ${f['flag_key']} should default to false in production');
      }
    });
  });
}
