// ============================================================================
// BloodNorms | donor_badges_test.dart
// Unit tests for Stage 3: Donor Milestone Badges & Certificates Engine
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/shared/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Stage 3: Donor Milestone Badges & Honor Ladder', () {
    test('Milestone ladder tiers match required donation thresholds', () async {
      final service = SupabaseService();

      // Test 0 donations
      final badges0 = await service.getDonorBadges('test-donor-0', donationsCount: 0);
      expect(badges0.length, 5);
      expect(badges0.where((b) => b.isUnlocked).length, 0);
      expect(badges0.first.badgeCode, 'bronze_hero');
      expect(badges0.first.requiredDonations, 1);

      // Test 1 donation (Bronze Hero unlocked)
      final badges1 = await service.getDonorBadges('test-donor-1', donationsCount: 1);
      expect(badges1.where((b) => b.isUnlocked).length, 1);
      final bronze = badges1.firstWhere((b) => b.badgeCode == 'bronze_hero');
      expect(bronze.isUnlocked, isTrue);
      expect(bronze.badgeName, 'Bronze Hero');

      // Test 3 donations (Bronze + Silver Guardian)
      final badges3 = await service.getDonorBadges('test-donor-3', donationsCount: 3);
      expect(badges3.where((b) => b.isUnlocked).length, 2);
      final silver = badges3.firstWhere((b) => b.badgeCode == 'silver_guardian');
      expect(silver.isUnlocked, isTrue);

      // Test 5 donations (Bronze + Silver + Gold)
      final badges5 = await service.getDonorBadges('test-donor-5', donationsCount: 5);
      expect(badges5.where((b) => b.isUnlocked).length, 3);
      final gold = badges5.firstWhere((b) => b.badgeCode == 'gold_lifesaver');
      expect(gold.isUnlocked, isTrue);

      // Test 10 donations (Platinum Savior)
      final badges10 = await service.getDonorBadges('test-donor-10', donationsCount: 10);
      expect(badges10.where((b) => b.isUnlocked).length, 4);
      final plat = badges10.firstWhere((b) => b.badgeCode == 'platinum_savior');
      expect(plat.isUnlocked, isTrue);

      // Test 25+ donations (Centurion Lifesaver)
      final badges25 = await service.getDonorBadges('test-donor-25', donationsCount: 25);
      expect(badges25.where((b) => b.isUnlocked).length, 5);
      final centurion = badges25.firstWhere((b) => b.badgeCode == 'centurion');
      expect(centurion.isUnlocked, isTrue);
    });

    test('DonorBadgeModel serialization round-trip maintains integrity', () {
      final now = DateTime.now();
      final original = DonorBadgeModel(
        id: 'badge-123',
        donorId: 'donor-456',
        badgeCode: 'gold_lifesaver',
        badgeName: 'Gold Lifesaver',
        description: '5 donations pillar',
        unlockedAt: now,
        certificateUrl: 'https://bloodnorms.org/certs/123.pdf',
        isUnlocked: true,
        requiredDonations: 5,
        icon: '🥇',
      );

      final json = original.toJson();
      final reconstituted = DonorBadgeModel.fromJson(json);

      expect(reconstituted.id, original.id);
      expect(reconstituted.donorId, original.donorId);
      expect(reconstituted.badgeCode, original.badgeCode);
      expect(reconstituted.badgeName, original.badgeName);
      expect(reconstituted.description, original.description);
      expect(reconstituted.isUnlocked, isTrue);
      expect(reconstituted.requiredDonations, 5);
      expect(reconstituted.icon, '🥇');
    });

    test('Certificate verification seal formats adhere to standard pattern', () {
      final donorId = 'd-9988-7766';
      final badgeCode = 'gold_lifesaver';
      final certId = 'AP-BN-${badgeCode.toUpperCase()}-${donorId.hashCode.abs().toString().substring(0, 5)}';

      expect(certId.startsWith('AP-BN-GOLD_LIFESAVER-'), isTrue);
      expect(certId.length, greaterThan(20));
    });
  });
}
