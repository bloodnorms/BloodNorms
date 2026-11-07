// ============================================================================
// BloodNorms | admin_bank_operations_service.dart
// Superhero Admin Direct Bank Operations: Stock Adjustments, Creation & Edits
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';
import 'admin_bank_stock_service.dart';

export 'admin_bank_stock_service.dart';

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
  }) =>
      AdminBankStockService().adjustBankStockQuick(
        bankId: bankId,
        bloodGroup: bloodGroup,
        deltaUnits: deltaUnits,
        component: component,
      );

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
  Future<Map<String, int>> getBankStockAllGroups(String bankId) =>
      AdminBankStockService().getBankStockAllGroups(bankId);

  /// Set Bank Stock Directly
  Future<bool> setBankStockDirect({
    required String bankId,
    required String bloodGroup,
    required int units,
    String component = 'whole_blood',
  }) =>
      AdminBankStockService().setBankStockDirect(
        bankId: bankId,
        bloodGroup: bloodGroup,
        units: units,
        component: component,
      );
}
