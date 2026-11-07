// ============================================================================
// BloodNorms | request_lifecycle_service.dart
// Request lifecycle state mutations: widening search rings, cancellation & fulfillment
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';

class RequestLifecycleService {
  static final RequestLifecycleService _instance =
      RequestLifecycleService._internal();
  factory RequestLifecycleService() => _instance;
  RequestLifecycleService._internal();

  SupabaseClient? get _client => SupabaseService().client;

  /// Widen request search radius
  Future<bool> widenRequest(
    String requestId,
    double newRadiusKm, {
    int wave = 1,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('requests').update({
          'current_ring_km': newRadiusKm,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', requestId);
        return true;
      } catch (e) {
        debugPrint('widenRequest error: $e');
      }
    }
    return false;
  }

  /// Close or cancel active request
  Future<bool> closeRequest(
    String requestId, {
    String outcome = 'resolved',
    String? status,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final st = status ??
            (outcome.toLowerCase().contains('cancel')
                ? 'cancelled'
                : 'fulfilled');
        await client.from('requests').update({
          'status': st,
          'outcome': outcome,
          'closed_at': DateTime.now().toIso8601String(),
        }).eq('id', requestId);

        if (st == 'cancelled') {
          try {
            await client.from('request_contacts').update({
              'status': 'cancelled',
            }).eq('request_id', requestId);
          } catch (_) {}
        }
        return true;
      } catch (e) {
        debugPrint('closeRequest error: $e');
      }
    }
    return false;
  }
}
