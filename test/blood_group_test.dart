// ============================================================================
// BloodNorms | test/blood_group_test.dart
// Unit tests for BloodGroup compatibility per BR-04
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bloodnorms/core/constants/blood_groups.dart';

void main() {
  group('BloodGroup Compatibility Tests (BR-04)', () {
    test('O- is universal red donor', () {
      for (final recipient in BloodGroup.values) {
        expect(BloodGroup.oNegative.canDonateTo(recipient), isTrue,
            reason: 'O- should be able to donate to ${recipient.label}');
      }
    });

    test('O+ can donate to all positive groups', () {
      expect(BloodGroup.oPositive.canDonateTo(BloodGroup.oPositive), isTrue);
      expect(BloodGroup.oPositive.canDonateTo(BloodGroup.aPositive), isTrue);
      expect(BloodGroup.oPositive.canDonateTo(BloodGroup.bPositive), isTrue);
      expect(BloodGroup.oPositive.canDonateTo(BloodGroup.abPositive), isTrue);

      expect(BloodGroup.oPositive.canDonateTo(BloodGroup.oNegative), isFalse);
      expect(BloodGroup.oPositive.canDonateTo(BloodGroup.aNegative), isFalse);
    });

    test('AB+ can receive from all, but can only donate to AB+', () {
      expect(BloodGroup.abPositive.canDonateTo(BloodGroup.abPositive), isTrue);
      expect(BloodGroup.abPositive.canDonateTo(BloodGroup.aPositive), isFalse);
      expect(BloodGroup.abPositive.canDonateTo(BloodGroup.bPositive), isFalse);
      expect(BloodGroup.abPositive.canDonateTo(BloodGroup.oPositive), isFalse);
    });

    test('Exact match is always compatible', () {
      for (final bg in BloodGroup.values) {
        expect(bg.canDonateTo(bg), isTrue);
      }
    });
  });
}

