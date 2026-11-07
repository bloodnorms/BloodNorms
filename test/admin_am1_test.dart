// ============================================================================
// BloodNorms | admin_am1_test.dart
// Milestone AM1 Verification: Four-Eyes Approvals, Step-Up & Session Security
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Milestone AM1: Four-Eyes Approval Matrix & Security Protocol', () {
    test('submitApprovalRequest queues request with 24-hour expiration', () async {
      final service = SupabaseService();
      final res = await service.submitApprovalRequest(
        actionType: 'broadcast.mass',
        targetEntity: 'campaign',
        targetId: 'camp-99',
        diffPayload: {'recipients': 400},
        reason: 'Emergency mobilization for regional camp',
        makerId: 'user-maker-01',
      );

      expect(res['action_type'], 'broadcast.mass');
      expect(res['status'], 'pending');
      expect(res['maker_id'], 'user-maker-01');

      final expiresAt = DateTime.parse(res['expires_at'].toString());
      final now = DateTime.now();
      expect(expiresAt.difference(now).inHours, inInclusiveRange(23, 24));
    });

    test('Four-eyes enforcement: Maker CANNOT approve their own request', () async {
      final service = SupabaseService();
      final req = await service.submitApprovalRequest(
        actionType: 'caps.change',
        diffPayload: {'new_cap': 120},
        reason: 'Raise daily AI minutes cap',
        makerId: 'user-siva-01',
      );

      final requestId = req['id'].toString();

      // Attempt to self-approve with maker ID
      final selfApproval = await service.decideApprovalRequest(
        requestId: requestId,
        approve: true,
        currentUserId: 'user-siva-01', // Same user!
      );

      expect(selfApproval['ok'], isFalse);
      expect(selfApproval['reason'], 'maker_cannot_be_checker');
    });

    test('Four-eyes enforcement: Second person (Checker) CAN approve request', () async {
      final service = SupabaseService();
      final req = await service.submitApprovalRequest(
        actionType: 'rate_card.change',
        diffPayload: {'new_rate': 0.45},
        reason: 'Updated Meta WhatsApp utility rate',
        makerId: 'user-finance-01',
      );

      final requestId = req['id'].toString();

      // Independent checker decides
      final checkerApproval = await service.decideApprovalRequest(
        requestId: requestId,
        approve: true,
        currentUserId: 'user-checker-02', // Different user!
        note: 'Verified with official Meta rate card',
      );

      expect(checkerApproval['ok'], isTrue);
      expect(checkerApproval['status'], 'approved');
    });

    test('Step-up verification enforces 6-digit numeric pattern', () async {
      final service = SupabaseService();

      // Invalid formats
      expect(await service.verifyStepUpCode('123'), isFalse);
      expect(await service.verifyStepUpCode('abcdef'), isFalse);
      expect(await service.verifyStepUpCode('1234567'), isFalse);

      // Valid 6-digit TOTP
      expect(await service.verifyStepUpCode('849201'), isTrue);
      expect(await service.hasActiveStepUp(), isTrue);
    });

    test('Break-glass elevation mandates at least 10 characters reason', () async {
      final service = SupabaseService();

      // Short reason fails
      final shortRes = await service.requestBreakGlassElevation(reason: 'urgent');
      expect(shortRes['ok'], isFalse);

      // Detailed reason succeeds with 2-hour TTL
      final validRes = await service.requestBreakGlassElevation(
        reason: 'Emergency database connectivity restoration after network split',
      );
      expect(validRes['ok'], isTrue);
      expect(validRes['expires_in_hours'], 2);
    });

    test('Admin sessions can be listed and remotely revoked', () async {
      final service = SupabaseService();
      final sessions = await service.getActiveAdminSessions();
      expect(sessions.isNotEmpty, isTrue);

      final revoked = await service.revokeAdminSession(sessions.first['id'].toString());
      expect(revoked, isTrue);
    });
  });
}

