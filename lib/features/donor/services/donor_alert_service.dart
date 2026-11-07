// ============================================================================
// BloodNorms | donor_alert_service.dart
// Donor emergency alert responses, donation code generation, and history
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/request_alert_model.dart';
import '../../../shared/services/supabase_service.dart';

class DonorAlertService {
  static final DonorAlertService _instance = DonorAlertService._internal();
  factory DonorAlertService() => _instance;
  DonorAlertService._internal();

  SupabaseClient? get _client => SupabaseService().client;

  /// Get live emergency alerts for donor
  Future<List<RequestAlertModel>> getDonorAlerts({String? bloodGroup}) async {
    final client = _client;
    if (client != null) {
      try {
        var filter =
            client.from('requests').select().eq('status', 'searching');

        if (bloodGroup != null && bloodGroup.isNotEmpty) {
          filter = filter.eq('blood_group', bloodGroup);
        }

        final res =
            await filter.order('created_at', ascending: false).limit(10);
        if (res.isNotEmpty) {
          return res
              .map((item) =>
                  RequestAlertModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } catch (e) {
        debugPrint('getDonorAlerts error: $e');
      }
    }
    return [];
  }

  /// Accept emergency donor alert and retrieve/generate donation code
  Future<String?> acceptDonorAlert({
    required String requestId,
    required String donorId,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final existing = await client
            .from('request_contacts')
            .select('id, donation_code')
            .eq('request_id', requestId)
            .eq('donor_id', donorId)
            .maybeSingle();

        if (existing != null && existing['donation_code'] != null) {
          await client.from('request_contacts').update({
            'status': 'accepted',
            'final_status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          }).eq('id', existing['id']);
          return existing['donation_code'].toString();
        }

        final code = (100000 + Random().nextInt(900000)).toString();
        await client.from('request_contacts').insert({
          'request_id': requestId,
          'donor_id': donorId,
          'status': 'accepted',
          'final_status': 'accepted',
          'donation_code': code,
          'accepted_at': DateTime.now().toIso8601String(),
        });

        final req = await client
            .from('requests')
            .select('donors_accepted')
            .eq('id', requestId)
            .maybeSingle();
        final current = (req?['donors_accepted'] as num?)?.toInt() ?? 0;
        await client.from('requests').update({
          'donors_accepted': current + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', requestId);

        return code;
      } catch (e) {
        debugPrint('acceptDonorAlert error: $e');
      }
    }
    return null;
  }

  /// Get past donation history
  Future<List<Map<String, dynamic>>> getDonorPastHistory(String donorId) async {
    final client = _client;
    if (client != null) {
      try {
        final donations = await client
            .from('donations')
            .select('id, code, confirmed_at, blood_group, units, requests(hospital_name, hospital_area)')
            .eq('donor_id', donorId)
            .order('confirmed_at', ascending: false);

        if (donations.isNotEmpty) {
          return List<Map<String, dynamic>>.from(donations);
        }

        final contacts = await client
            .from('request_contacts')
            .select('id, donation_code, accepted_at, donated_at, status, requests(hospital_name, hospital_area, blood_group)')
            .eq('donor_id', donorId)
            .inFilter('status', ['donated', 'completed'])
            .order('accepted_at', ascending: false);

        return List<Map<String, dynamic>>.from(contacts);
      } catch (e) {
        debugPrint('getDonorPastHistory error: $e');
      }
    }
    return [];
  }
}
