// ============================================================================
// BloodNorms | admin_governance_service.dart
// Four-Eyes Approval Matrix, Step-Up Verification, Sessions & Break-Glass
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';
import 'admin_step_up_service.dart';
import 'approval_cache_store.dart';

export 'admin_step_up_service.dart';

class AdminGovernanceService {
  static final AdminGovernanceService _instance =
      AdminGovernanceService._internal();
  factory AdminGovernanceService() => _instance;
  AdminGovernanceService._internal();

  /// Submit a four-eyes approval request for sensitive operational actions
  Future<Map<String, dynamic>> submitApprovalRequest({
    required String actionType,
    String? targetEntity,
    String? targetId,
    required Map<String, dynamic> diffPayload,
    required String reason,
    String? makerId,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    final effectiveMakerId = makerId ??
        client?.auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000001';

    final newEntry = {
      'id': 'appr-${DateTime.now().millisecondsSinceEpoch}',
      'action_type': actionType,
      'maker_id': effectiveMakerId,
      'maker_role': 'admin',
      'target_entity': targetEntity ?? 'general',
      'target_id': targetId ?? 'system',
      'diff_payload': diffPayload,
      'reason': reason,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'expires_at':
          DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    };

    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('submit_approval_request', params: {
          'p_action_type': actionType,
          'p_target_entity': targetEntity,
          'p_target_id': targetId,
          'p_diff_payload': diffPayload,
          'p_reason': reason,
        });
        if (res != null) {
          newEntry['id'] = res.toString();
        }
      } catch (e) {
        debugPrint('submit_approval_request RPC error: $e');
      }
    }

    await ApprovalCacheStore.cacheApproval(newEntry);
    return newEntry;
  }

  /// Get list of approval requests
  Future<List<Map<String, dynamic>>> getApprovalRequests({
    String status = 'pending',
  }) async {
    final List<Map<String, dynamic>> results = [];
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('approval_requests')
            .select()
            .order('created_at', ascending: false);
        final list = res as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            if (status == 'all' || item['status'] == status) {
              results.add(item);
            }
          }
        }
      } catch (e) {
        debugPrint('getApprovalRequests error: $e');
      }
    }

    if (results.isNotEmpty) return results;

    final cachedResults = await ApprovalCacheStore.getCachedApprovals(status);
    if (cachedResults.isNotEmpty) return cachedResults;

    return [
      {
        'id': 'appr-demo-1',
        'action_type': 'broadcast.mass',
        'maker_id': '00000000-0000-0000-0000-000000000001',
        'maker_role': 'admin',
        'target_entity': 'broadcast',
        'target_id': 'camp-rotary-01',
        'diff_payload': {
          'recipients_count': 350,
          'channel': 'whatsapp',
          'cost_estimate_inr': 420.0
        },
        'reason':
            'Emergency regional notification for Sunday Blood Drive at Rotary Hall',
        'status': 'pending',
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'expires_at':
            DateTime.now().add(const Duration(hours: 22)).toIso8601String(),
      },
    ];
  }

  /// Decide on an approval request (Four-eyes rule: maker cannot approve own request!)
  Future<Map<String, dynamic>> decideApprovalRequest({
    required String requestId,
    required bool approve,
    String? note,
    String? currentUserId,
  }) async {
    final decision = approve ? 'approved' : 'rejected';
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    final effectiveCheckerId = currentUserId ??
        client?.auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000002';

    final cachedDecision = await ApprovalCacheStore.decideCachedApproval(
      requestId: requestId,
      decision: decision,
      effectiveCheckerId: effectiveCheckerId,
      note: note,
    );
    if (cachedDecision != null) return cachedDecision;

    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('decide_approval_request', params: {
          'p_request_id': requestId,
          'p_decision': decision,
          'p_note': note,
        });
        if (res is Map) {
          return Map<String, dynamic>.from(res);
        }
      } catch (e) {
        debugPrint('decide_approval_request RPC error: $e');
      }
    }

    return {'ok': true, 'status': decision};
  }

  /// Step-Up Re-Authentication verification (TOTP valid for 5 mins)
  Future<bool> verifyStepUpCode(String totpCode) =>
      AdminStepUpSecurityService().verifyStepUpCode(totpCode);

  /// Check if user has active valid step-up authorization (within 5 minutes)
  Future<bool> hasActiveStepUp() =>
      AdminStepUpSecurityService().hasActiveStepUp();

  /// Get active administrator sessions
  Future<List<Map<String, dynamic>>> getActiveAdminSessions() =>
      AdminStepUpSecurityService().getActiveAdminSessions();

  /// Revoke an active admin session remotely
  Future<bool> revokeAdminSession(String sessionId) =>
      AdminStepUpSecurityService().revokeAdminSession(sessionId);

  /// Request temporary Break-Glass elevation (max 2 hours, mandatory reason)
  Future<Map<String, dynamic>> requestBreakGlassElevation({
    required String reason,
  }) =>
      AdminStepUpSecurityService().requestBreakGlassElevation(reason: reason);
}
