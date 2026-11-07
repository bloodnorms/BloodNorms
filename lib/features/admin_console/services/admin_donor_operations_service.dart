// ============================================================================
// BloodNorms | admin_donor_operations_service.dart
// Superhero Admin Direct Donor Operations: Trust Level, Manual Creation, Edits
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminDonorOperationsService {
  static final AdminDonorOperationsService _instance =
      AdminDonorOperationsService._internal();
  factory AdminDonorOperationsService() => _instance;
  AdminDonorOperationsService._internal();

  /// Promote Donor Trust Level
  Future<bool> updateDonorTrustLevel(String donorId, int trustLevel) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        await client.from('donors').update({
          'trust_level': trustLevel,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', donorId);

        await client.from('audit_logs').insert({
          'action': 'donor_trust_promoted',
          'target_type': 'donors',
          'target_id': donorId,
          'meta': {'new_trust_level': trustLevel},
        });
        return true;
      } catch (e) {
        debugPrint('updateDonorTrustLevel error: $e');
      }
    }
    return false;
  }

  /// Create Donor Manually
  Future<Map<String, dynamic>> createDonorDirect({
    required String fullName,
    required String phone,
    required String bloodGroup,
    int trustLevel = 1,
    String gender = 'other',
    int maxTravelKm = 10,
    String state = 'active',
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.from('donors').insert({
          'full_name': fullName,
          'first_name': fullName.split(' ').first,
          'phone': phone,
          'blood_group': bloodGroup,
          'trust_level': trustLevel,
          'gender': gender,
          'max_travel_km': maxTravelKm,
          'state': state,
          'donations_count': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).select().single();

        await client.from('audit_logs').insert({
          'action': 'admin_create_donor',
          'target_type': 'donors',
          'target_id': res['id'],
          'meta': {'name': fullName, 'phone': phone, 'group': bloodGroup},
        });
        return {'success': true, 'donor': res};
      } catch (e) {
        debugPrint('createDonorDirect error: $e');
        return {'success': false, 'error': e.toString()};
      }
    }
    return {'success': false, 'error': 'Database disconnected'};
  }

  /// Update Donor Details
  Future<bool> updateDonorDirect({
    required String id,
    String? fullName,
    String? phone,
    String? bloodGroup,
    String? state,
    int? trustLevel,
    String? gender,
    int? maxTravelKm,
    int? donationsCount,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final updates = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (fullName != null) {
          updates['full_name'] = fullName;
          updates['first_name'] = fullName.split(' ').first;
        }
        if (phone != null) updates['phone'] = phone;
        if (bloodGroup != null) updates['blood_group'] = bloodGroup;
        if (state != null) updates['state'] = state;
        if (trustLevel != null) updates['trust_level'] = trustLevel;
        if (gender != null) updates['gender'] = gender;
        if (maxTravelKm != null) updates['max_travel_km'] = maxTravelKm;
        if (donationsCount != null) updates['donations_count'] = donationsCount;

        await client.from('donors').update(updates).eq('id', id);
        await client.from('audit_logs').insert({
          'action': 'admin_update_donor',
          'target_type': 'donors',
          'target_id': id,
          'meta': updates,
        });
        return true;
      } catch (e) {
        debugPrint('updateDonorDirect error: $e');
      }
    }
    return false;
  }
}
