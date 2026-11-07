// ============================================================================
// BloodNorms | admin_bank_operations_service.dart
// Superhero Admin Direct Bank Operations: Stock Adjustments, Creation & Edits
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminBankOperationsService {
  static final AdminBankOperationsService _instance =
      AdminBankOperationsService._internal();
  factory AdminBankOperationsService() => _instance;
  AdminBankOperationsService._internal();

  /// Quick Bank Stock Adjustment (+ / - units)
  Future<bool> adjustBankStockQuick({
    required String bankId,
    required String bloodGroup,
    required int deltaUnits,
    String component = 'whole_blood',
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final existing = await client
            .from('bank_stock')
            .select('id, units')
            .eq('bank_id', bankId)
            .eq('blood_group', bloodGroup)
            .eq('component', component)
            .maybeSingle();

        final currentUnits = (existing?['units'] as num?)?.toInt() ?? 0;
        final newUnits = (currentUnits + deltaUnits).clamp(0, 999);

        if (existing != null) {
          await client.from('bank_stock').update({
            'units': newUnits,
            'updated_at': DateTime.now().toIso8601String(),
            'source': 'admin_quick_adjust',
          }).eq('id', existing['id']);
        } else {
          await client.from('bank_stock').insert({
            'bank_id': bankId,
            'blood_group': bloodGroup,
            'component': component,
            'units': newUnits,
            'source': 'admin_quick_adjust',
          });
        }

        await client.from('audit_logs').insert({
          'action': 'admin_quick_stock_adjust',
          'target_type': 'bank_stock',
          'target_id': bankId,
          'meta': {
            'group': bloodGroup,
            'delta': deltaUnits,
            'new_units': newUnits,
          },
        });
        return true;
      } catch (e) {
        debugPrint('adjustBankStockQuick error: $e');
      }
    }
    return false;
  }

  /// Update Blood Bank Meta
  Future<bool> updateBloodBank({
    required String bankId,
    double? trustScore,
    bool? is24x7,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final updates = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (trustScore != null) updates['trust_score'] = trustScore;
        if (is24x7 != null) updates['is_24x7'] = is24x7;

        await client.from('blood_banks').update(updates).eq('id', bankId);
        await client.from('audit_logs').insert({
          'action': 'admin_bank_update',
          'target_type': 'blood_banks',
          'target_id': bankId,
          'meta': updates,
        });
        return true;
      } catch (e) {
        debugPrint('updateBloodBank error: $e');
      }
    }
    return false;
  }

  /// Create Blood Bank
  Future<Map<String, dynamic>> createBloodBankDirect({
    required String name,
    required String address,
    required String phone,
    bool is24x7 = true,
    int trustScore = 85,
    String contactPerson = '',
    double lat = 17.0005,
    double lng = 81.7800,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.from('blood_banks').insert({
          'name': name,
          'address': address,
          'phones': [phone],
          'is_24x7': is24x7,
          'trust_score': trustScore,
          'contact_person': contactPerson,
          'lat': lat,
          'lng': lng,
          'bank_type': 'hospital_blood_bank',
          'hours': is24x7 ? '24 Hours' : '8:00 AM - 8:00 PM',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).select().single();

        final bankId = res['id']?.toString() ?? '';
        final groups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
        for (final bg in groups) {
          await client.from('bank_stock').insert({
            'bank_id': bankId,
            'blood_group': bg,
            'component': 'whole_blood',
            'units': 5,
            'source': 'initial_seed',
          });
        }

        await client.from('audit_logs').insert({
          'action': 'admin_create_blood_bank',
          'target_type': 'blood_banks',
          'target_id': bankId,
          'meta': {'name': name, 'phone': phone},
        });
        return {'success': true, 'bank': res};
      } catch (e) {
        debugPrint('createBloodBankDirect error: $e');
        return {'success': false, 'error': e.toString()};
      }
    }
    return {'success': false, 'error': 'Database disconnected'};
  }

  /// Update Blood Bank Full
  Future<bool> updateBloodBankFull({
    required String id,
    String? name,
    String? address,
    String? phone,
    bool? is24x7,
    int? trustScore,
    String? contactPerson,
    double? lat,
    double? lng,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final updates = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (name != null) updates['name'] = name;
        if (address != null) updates['address'] = address;
        if (phone != null) updates['phones'] = [phone];
        if (is24x7 != null) {
          updates['is_24x7'] = is24x7;
          updates['hours'] = is24x7 ? '24 Hours' : '8:00 AM - 8:00 PM';
        }
        if (trustScore != null) updates['trust_score'] = trustScore;
        if (contactPerson != null) updates['contact_person'] = contactPerson;
        if (lat != null) updates['lat'] = lat;
        if (lng != null) updates['lng'] = lng;

        await client.from('blood_banks').update(updates).eq('id', id);
        await client.from('audit_logs').insert({
          'action': 'admin_update_blood_bank_full',
          'target_type': 'blood_banks',
          'target_id': id,
          'meta': updates,
        });
        return true;
      } catch (e) {
        debugPrint('updateBloodBankFull error: $e');
      }
    }
    return false;
  }

  /// Get Stock Breakdown for All 8 Groups
  Future<Map<String, int>> getBankStockAllGroups(String bankId) async {
    final result = <String, int>{
      'O+': 0, 'O-': 0, 'A+': 0, 'A-': 0,
      'B+': 0, 'B-': 0, 'AB+': 0, 'AB-': 0,
    };
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final rows = await client
            .from('bank_stock')
            .select('blood_group, units')
            .eq('bank_id', bankId);
        for (final r in rows) {
          final bg = r['blood_group']?.toString() ?? '';
          final units = (r['units'] as num?)?.toInt() ?? 0;
          if (result.containsKey(bg)) {
            result[bg] = units;
          }
        }
      } catch (e) {
        debugPrint('getBankStockAllGroups error: $e');
      }
    }
    return result;
  }

  /// Set Bank Stock Directly
  Future<bool> setBankStockDirect({
    required String bankId,
    required String bloodGroup,
    required int units,
    String component = 'whole_blood',
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final existing = await client
            .from('bank_stock')
            .select('id')
            .eq('bank_id', bankId)
            .eq('blood_group', bloodGroup)
            .eq('component', component)
            .maybeSingle();

        if (existing != null) {
          await client.from('bank_stock').update({
            'units': units,
            'updated_at': DateTime.now().toIso8601String(),
            'source': 'admin_direct_set',
          }).eq('id', existing['id']);
        } else {
          await client.from('bank_stock').insert({
            'bank_id': bankId,
            'blood_group': bloodGroup,
            'component': component,
            'units': units,
            'source': 'admin_direct_set',
          });
        }

        await client.from('audit_logs').insert({
          'action': 'admin_set_stock_direct',
          'target_type': 'bank_stock',
          'target_id': bankId,
          'meta': {'group': bloodGroup, 'units': units},
        });
        return true;
      } catch (e) {
        debugPrint('setBankStockDirect error: $e');
      }
    }
    return false;
  }
}
