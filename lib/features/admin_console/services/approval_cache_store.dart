// ============================================================================
// BloodNorms | approval_cache_store.dart
// SharedPreferences persistence and validation for 4-Eyes approval requests
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApprovalCacheStore {
  static const String _key = 'local_approvals_cache';

  static Future<void> cacheApproval(Map<String, dynamic> entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_key);
      List list = cached != null ? jsonDecode(cached) as List : [];
      list.insert(0, entry);
      await prefs.setString(_key, jsonEncode(list));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getCachedApprovals(
      String status) async {
    final List<Map<String, dynamic>> results = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_key);
      if (cached != null) {
        final List list = jsonDecode(cached) as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            if (status == 'all' || item['status'] == status) {
              results.add(item);
            }
          }
        }
      }
    } catch (_) {}
    return results;
  }

  static Future<Map<String, dynamic>?> decideCachedApproval({
    required String requestId,
    required String decision,
    required String effectiveCheckerId,
    String? note,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_key);
      if (cached != null) {
        final List list = jsonDecode(cached) as List;
        for (final item in list) {
          if (item is Map && item['id'] == requestId) {
            if (item['maker_id'] == effectiveCheckerId) {
              return {'ok': false, 'reason': 'maker_cannot_be_checker'};
            }
            final expiresAt =
                DateTime.tryParse(item['expires_at']?.toString() ?? '');
            if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
              item['status'] = 'expired';
              await prefs.setString(_key, jsonEncode(list));
              return {'ok': false, 'reason': 'expired'};
            }
            item['status'] = decision;
            item['checker_id'] = effectiveCheckerId;
            item['checker_note'] = note;
            item['decided_at'] = DateTime.now().toIso8601String();
          }
        }
        await prefs.setString(_key, jsonEncode(list));
      }
    } catch (_) {}
    return null;
  }
}
