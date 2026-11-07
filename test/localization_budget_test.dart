// ============================================================================
// BloodNorms | test/localization_budget_test.dart
// Automated Design Check per 05-UI-UX-DESIGN-SYSTEM.md §14.3
// Verifies string budget (<= 28 chars for UI strings) and en/te/hi parity
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloodnorms/shared/i18n/app_localizations.dart';

void main() {
  group('String Budget & Localization Parity Tests (§14.3)', () {
    final en = AppLocalizations(const Locale('en'));
    final te = AppLocalizations(const Locale('te'));
    final hi = AppLocalizations(const Locale('hi'));

    final testKeys = [
      'app.name', 'home.need', 'home.donor', 'home.banks', 'home.whatsapp',
      'group.title', 'group.unknown', 'units.title', 'urgency.now', 'urgency.6h',
      'urgency.24h', 'type.whole', 'type.red', 'type.platelets', 'type.plasma',
      'loc.use', 'loc.search', 'banks.title', 'banks.call', 'banks.unknown',
      'cta.search', 'cta.continue', 'cta.send', 'cta.stop', 'cta.done',
      'cta.call', 'cta.save', 'cta.cancel', 'cta.yes', 'cta.no',
      'live.contacted', 'live.accepted', 'live.need', 'live.standby', 'live.got',
      'gate.title', 'gate.far', 'code.title', 'donor.active', 'donor.almost',
      'donor.next', 'donor.available', 'donor.pause', 'donor.delete',
      'bank.stock', 'bank.confirm', 'bank.expected', 'bank.camps', 'bank.notdonated',
      'common.offline', 'common.language', 'common.help', 'safety.money',
    ];

    test('All keys present in en, te, hi', () {
      for (final key in testKeys) {
        expect(en.t(key), isNotEmpty, reason: 'Key $key missing in EN');
        expect(te.t(key), isNotEmpty, reason: 'Key $key missing in TE');
        expect(hi.t(key), isNotEmpty, reason: 'Key $key missing in HI');
      }
    });

    test('All core UI strings adhere to the 28-character budget (§9 & §14.3)', () {
      for (final key in testKeys) {
        // Exclude legal / safety warnings from strict 28 char budget
        if (key == 'safety.money') continue;

        final enText = en.t(key);
        final teText = te.t(key);
        final hiText = hi.t(key);

        expect(enText.length, lessThanOrEqualTo(28),
            reason: 'EN string "$enText" for key $key exceeds 28 characters');
        expect(teText.length, lessThanOrEqualTo(28),
            reason: 'TE string "$teText" for key $key exceeds 28 characters');
        expect(hiText.length, lessThanOrEqualTo(28),
            reason: 'HI string "$hiText" for key $key exceeds 28 characters');
      }
    });
  });
}

