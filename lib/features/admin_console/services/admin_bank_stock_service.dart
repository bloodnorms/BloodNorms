// ============================================================================
// BloodNorms | admin_bank_stock_service.dart
// Blood Bank Stock Inventory Management & Adjustments for Admin Operations
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminBankStockService {
  static final AdminBankStockService _instance =
      AdminBankStockService._internal();
  factory AdminBankStockService() => _instance;
  AdminBankStockService._internal();

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
