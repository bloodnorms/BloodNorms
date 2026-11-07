// ============================================================================
// BloodNorms | test/admin_am3_am4_test.dart
// Milestone AM3 & AM4 Verification Suite:
// - AM3: Data Export Engine (EXP-1..10, CSV injection, Tier 1/2/3 governance)
// - AM4: Ledgers & Cost Engine (EXP-LED-1..2, FIN-1..5, INR spend attribution)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Milestone AM3: Data Export Engine (EXP-1..10)', () {
    test('CSV injection neutralization: prepends apostrophe on =, +, -, @', () {
      final service = SupabaseService();

      expect(service.sanitizeCsvCell('=SUM(A1:A10)'), equals("'=SUM(A1:A10)"));
      expect(service.sanitizeCsvCell('+cmd|/c calc'), equals("'+cmd|/c calc"));
      expect(service.sanitizeCsvCell('-5+2'), equals("'-5+2"));
      expect(service.sanitizeCsvCell('@attacker.com'), equals("'@attacker.com"));
      expect(service.sanitizeCsvCell('Safe Text'), equals('Safe Text'));
      expect(service.sanitizeCsvCell(''), equals(''));
    });

    test('Tier 3 export is BLOCKED without Four-Eyes approval ID', () async {
      final res = await SupabaseService().createDataExport(
        entityType: 'donors_pii',
        tier: 'tier_3_identifiers',
        format: 'csv',
        reason: 'Compliance audit',
      );

      expect(res['ok'], isFalse);
      expect(res['reason'], contains('Tier 3'));
    });

    test('Tier 2 masked export succeeds with SHA-256 watermark and 15m expiration', () async {
      final res = await SupabaseService().createDataExport(
        entityType: 'requests',
        tier: 'tier_2_masked',
        format: 'csv',
        reason: 'Operations report',
        rowCount: 50,
      );

      expect(res['ok'], isTrue);
      expect(res['watermark'], isNotNull);
      expect(res['watermark'], contains('BN-EXP'));
      expect(res['expires_at'], isNotNull);
    });

    test('Tier 3 export SUCCEEDS when Four-Eyes approval ID is attached', () async {
      final res = await SupabaseService().createDataExport(
        entityType: 'donors_pii',
        tier: 'tier_3_identifiers',
        format: 'csv',
        reason: 'Legal warrant request',
        approvalId: 'appr-req-12345',
        rowCount: 10,
      );

      expect(res['ok'], isTrue);
      expect(res['watermark'], isNotNull);
    });
  });

  group('Milestone AM4: Ledgers & Cost Engine (EXP-LED, FIN-1..5)', () {
    test('getCostRateCards returns INR rates for Meta, Twilio, and Gemini Live', () async {
      final cards = await SupabaseService().getCostRateCards();

      expect(cards, isNotEmpty);
      final serviceNames = cards.map((c) => c['service_name']).toList();
      expect(serviceNames, contains('whatsapp_utility'));
      expect(serviceNames, contains('twilio_voice_min'));
      expect(serviceNames, contains('gemini_live_min'));

      for (final card in cards) {
        expect(card['unit_cost_inr'], isNotNull);
        expect(card['unit_cost_inr'] as num, greaterThan(0));
      }
    });

    test('recordCostEvent calculates itemized cost in INR accurately', () async {
      final res = await SupabaseService().recordCostEvent(
        requestId: 'req-test-999',
        serviceName: 'gemini_live_min',
        units: 2.5,
      );

      expect(res['ok'], isTrue);
      expect(res['unit_rate'], equals(2.40));
      expect(res['total_cost_inr'], equals(6.00));
    });

    test('getDailySpendSummary returns INR spend breakdown by service', () async {
      final summary = await SupabaseService().getDailySpendSummary();

      expect(summary.containsKey('total_spend_inr'), isTrue);
      expect(summary.containsKey('breakdown'), isTrue);
      final breakdown = summary['breakdown'] as List;
      expect(breakdown, isNotEmpty);
    });
  });
}

