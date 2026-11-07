// ============================================================================
// BloodNorms | admin_camp_operations_service.dart
// Superhero Admin Direct Camp Operations: Updates, Deletions & Broadcasts
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminCampOperationsService {
  static final AdminCampOperationsService _instance =
      AdminCampOperationsService._internal();
  factory AdminCampOperationsService() => _instance;
  AdminCampOperationsService._internal();

  /// Update Blood Camp
  Future<bool> updateCampDirect({
    required String id,
    String? title,
    String? venue,
    String? area,
    DateTime? startsAt,
    DateTime? endsAt,
    int? capacity,
    String? status,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final updates = <String, dynamic>{};
        if (title != null) updates['title'] = title;
        if (venue != null) updates['venue'] = venue;
        if (area != null) updates['area'] = area;
        if (startsAt != null) updates['starts_at'] = startsAt.toIso8601String();
        if (endsAt != null) updates['ends_at'] = endsAt.toIso8601String();
        if (capacity != null) updates['capacity'] = capacity;
        if (status != null) updates['status'] = status;

        await client.from('bank_camps').update(updates).eq('id', id);
        await client.from('audit_logs').insert({
          'action': 'admin_update_camp',
          'target_type': 'bank_camps',
          'target_id': id,
          'meta': updates,
        });
        return true;
      } catch (e) {
        debugPrint('updateCampDirect error: $e');
      }
    }
    return false;
  }

  /// Delete Blood Camp
  Future<bool> deleteCampDirect(String id) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        await client.from('bank_camps').delete().eq('id', id);
        await client.from('audit_logs').insert({
          'action': 'admin_delete_camp',
          'target_type': 'bank_camps',
          'target_id': id,
        });
        return true;
      } catch (e) {
        debugPrint('deleteCampDirect error: $e');
      }
    }
    return false;
  }

  /// Get Outbound Broadcast History
  Future<List<Map<String, dynamic>>> getBroadcastHistory() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('message_events')
            .select()
            .eq('direction', 'outbound')
            .order('created_at', ascending: false)
            .limit(20);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getBroadcastHistory error: $e');
      }
    }
    return [];
  }
}
