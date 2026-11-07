// ============================================================================
// BloodNorms | admin_platform_service.dart
// Admin platform status, kill switch control, and recent activity logs
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';

class AdminPlatformService {
  static final AdminPlatformService _instance =
      AdminPlatformService._internal();
  factory AdminPlatformService() => _instance;
  AdminPlatformService._internal();

  SupabaseClient? get _client => SupabaseService().client;

  /// Live platform counts (Donors, Banks, Camps)
  Future<Map<String, int>> getPlatformStats() async {
    final client = _client;
    if (client != null) {
      try {
        final dRes = await client.from('donors').count(CountOption.exact);
        final bRes = await client.from('blood_banks').count(CountOption.exact);
        final cRes = await client.from('bank_camps').count(CountOption.exact);
        return {
          'donors': dRes,
          'banks': bRes,
          'camps': cRes,
        };
      } catch (e) {
        debugPrint('getPlatformStats error: $e');
      }
    }
    return {'donors': 5, 'banks': 5, 'camps': 3};
  }

  /// Master kill switch status
  Future<bool> getKillSwitch() async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('app_settings')
            .select('value')
            .eq('key', 'kill_switch')
            .maybeSingle();
        if (res != null && res['value'] != null) {
          return res['value'] == true;
        }
      } catch (e) {
        debugPrint('getKillSwitch error: $e');
      }
    }
    return false;
  }

  /// Toggle master kill switch
  Future<bool> setKillSwitch(bool active) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('app_settings').upsert({
          'key': 'kill_switch',
          'value': active,
          'updated_at': DateTime.now().toIso8601String(),
        });
        return true;
      } catch (e) {
        debugPrint('setKillSwitch error: $e');
      }
    }
    return false;
  }

  /// Recent platform activity log
  Future<List<Map<String, dynamic>>> getRecentActivityLog() async {
    final list = <Map<String, dynamic>>[];
    final client = _client;
    if (client != null) {
      try {
        final dons = await client
            .from('donations')
            .select('id, code, confirmed_at, blood_group, units, confirmed_by')
            .order('confirmed_at', ascending: false)
            .limit(5);

        for (var d in dons) {
          final time = d['confirmed_at']?.toString() ?? '';
          list.add({
            'time': time.length > 10 ? time.substring(0, 10) : 'Recent',
            'action': 'bank_confirm',
            'detail':
                'Code ${d['code']} verified (${d['blood_group']} ${d['units']} unit) by ${d['confirmed_by'] ?? 'staff'}',
          });
        }

        final reqs = await client
            .from('requests')
            .select('id, hospital_name, blood_group, units_needed, status, created_at')
            .order('created_at', ascending: false)
            .limit(5);

        for (var r in reqs) {
          final time = r['created_at']?.toString() ?? '';
          list.add({
            'time': time.length > 10 ? time.substring(0, 10) : 'Recent',
            'action': 'emergency_req',
            'detail':
                '${r['blood_group']} needed at ${r['hospital_name']} (${r['status']})',
          });
        }
      } catch (e) {
        debugPrint('getRecentActivityLog error: $e');
      }
    }
    return list;
  }
}
