// ============================================================================
// BloodNorms | admin_maintenance_service.dart
// Scoped Maintenance Mode, Dynamic Policy Switches & Window Management
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';

class AdminMaintenanceService {
  static final AdminMaintenanceService _instance =
      AdminMaintenanceService._internal();
  factory AdminMaintenanceService() => _instance;
  AdminMaintenanceService._internal();

  /// Check maintenance status for a specific scope (web, donor, bank, public, etc.)
  Future<Map<String, dynamic>> checkMaintenanceStatus({
    required String scope,
    String? identifier,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('check_maintenance_status', params: {
          'p_scope': scope,
          'p_identifier': identifier,
        });
        if (res != null && res is Map<String, dynamic>) {
          return res;
        }
      } catch (e) {
        debugPrint('checkMaintenanceStatus error: $e');
      }
    }

    bool active = false;
    List<String> scopes = [
      'web',
      'donor',
      'bank',
      'public',
      'whatsapp',
      'phone',
      'api',
      'admin'
    ];
    try {
      final prefs = await SharedPreferences.getInstance();
      active = prefs.getBool('pref_maintenance_active') ?? false;
      scopes = prefs.getStringList('pref_maintenance_scopes') ?? scopes;
    } catch (_) {}
    final isScopeActive = active && scopes.contains(scope);

    return {
      'active': isScopeActive,
      'is_maintenance': active,
      'bypassed': false,
      'scope': scope,
      'policy': 'continue_active',
      'messages': {
        'en':
            'Scheduled maintenance in progress. Emergency helpline remains active.',
        'te':
            'నిర్వహణ పనులు జరుగుతున్నాయి. అత్యవసర రక్త సహాయం అందుబాటులో ఉంది.',
        'hi': 'रखरखाव कार्य प्रगति पर है। आपातकालीन रक्त हेल्पलाइन सक्रिय है।'
      }
    };
  }

  /// Get list of maintenance windows
  Future<List<Map<String, dynamic>>> getMaintenanceWindows() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('maintenance_windows')
            .select()
            .order('created_at', ascending: false)
            .limit(20);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getMaintenanceWindows error: $e');
      }
    }
    bool active = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      active = prefs.getBool('pref_maintenance_active') ?? false;
    } catch (_) {}

    return [
      {
        'id': 'win-default-01',
        'title': 'System Core Maintenance Window',
        'scopes': ['web', 'donor', 'bank', 'public'],
        'status': active ? 'active' : 'scheduled',
        'inflight_policy': 'continue_active',
        'scheduled_start': DateTime.now().toIso8601String(),
        'scheduled_end':
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'reason': 'Database indexes and capacity upgrade',
        'bypass_allowlist': {
          'phones': ['+919876543210'],
          'admin_ids': [],
          'ips': ['127.0.0.1']
        },
        'created_at': DateTime.now().toIso8601String(),
      }
    ];
  }

  /// Activate or deactivate maintenance mode with scopes, policy, and audit logging
  Future<Map<String, dynamic>> setMaintenanceMode({
    required bool active,
    List<String>? scopes,
    String policy = 'continue_active',
    String reason = 'Scheduled maintenance window',
    int durationMinutes = 60,
    Map<String, dynamic>? bypassAllowlist,
  }) async {
    final effectiveScopes = scopes ??
        ['web', 'donor', 'bank', 'public', 'whatsapp', 'phone', 'api'];

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_maintenance_active', active);
      await prefs.setStringList('pref_maintenance_scopes', effectiveScopes);
    } catch (_) {}

    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('set_maintenance_mode', params: {
          'p_active': active,
          'p_scopes': effectiveScopes,
          'p_policy': policy,
          'p_reason': reason,
          'p_duration_minutes': durationMinutes,
          'p_bypass_allowlist': bypassAllowlist ??
              {'phones': [], 'admin_ids': [], 'ips': []},
        });
        if (res != null && res is Map<String, dynamic>) {
          return res;
        }
      } catch (e) {
        debugPrint('setMaintenanceMode error: $e');
      }
    }

    return {
      'ok': true,
      'active': active,
      'window_id': 'mock-win-${DateTime.now().millisecondsSinceEpoch}'
    };
  }

  /// Extend active maintenance window
  Future<Map<String, dynamic>> extendMaintenanceWindow({
    required String windowId,
    required int additionalMinutes,
    String reason = 'Additional migration verification required',
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('extend_maintenance_window', params: {
          'p_window_id': windowId,
          'p_additional_minutes': additionalMinutes,
          'p_reason': reason,
        });
        if (res != null && res is Map<String, dynamic>) {
          return res;
        }
      } catch (e) {
        debugPrint('extendMaintenanceWindow error: $e');
      }
    }
    return {
      'ok': true,
      'new_end': DateTime.now()
          .add(Duration(minutes: additionalMinutes))
          .toIso8601String()
    };
  }

  /// Helper to check if global maintenance mode is active
  Future<bool> isMaintenanceActive() async {
    final status = await checkMaintenanceStatus(scope: 'web');
    return status['active'] == true || status['is_maintenance'] == true;
  }
}
