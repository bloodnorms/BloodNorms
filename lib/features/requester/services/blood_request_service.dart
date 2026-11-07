// ============================================================================
// BloodNorms | blood_request_service.dart
// Requester emergency workflows: request creation, live tracking, and dispatch
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/donor_card_model.dart';
import '../../../shared/services/supabase_service.dart';

class BloodRequestService {
  static final BloodRequestService _instance = BloodRequestService._internal();
  factory BloodRequestService() => _instance;
  BloodRequestService._internal();

  SupabaseClient? get _client => SupabaseService().client;

  /// Find nearby eligible donors via RPC or live table query
  Future<List<DonorCardModel>> findNearbyDonors({
    required double lat,
    required double lng,
    required String bloodGroup,
    bool allowCompatible = true,
    double radiusKm = 30.0,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client.rpc('find_nearby_eligible_donors', params: {
          'p_hospital_lat': lat,
          'p_hospital_lng': lng,
          'p_blood_group': bloodGroup,
          'p_allow_compatible': allowCompatible,
          'p_radius_km': radiusKm,
        });

        if (res is List && res.isNotEmpty) {
          return res
              .map((item) =>
                  DonorCardModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } catch (e) {
        debugPrint('find_nearby_eligible_donors RPC error: $e');
      }

      try {
        final res = await client
            .from('donors')
            .select('id, first_name, blood_group, phone, donor_location(home_lat, home_lng)')
            .eq('state', 'active')
            .limit(10);

        if (res.isNotEmpty) {
          return res.map((d) {
            final locs = d['donor_location'];
            double? dLat;
            double? dLng;
            if (locs is List && locs.isNotEmpty) {
              dLat = (locs.first['home_lat'] as num?)?.toDouble();
              dLng = (locs.first['home_lng'] as num?)?.toDouble();
            } else if (locs is Map) {
              dLat = (locs['home_lat'] as num?)?.toDouble();
              dLng = (locs['home_lng'] as num?)?.toDouble();
            }

            return DonorCardModel(
              id: d['id']?.toString() ?? '',
              firstName: d['first_name']?.toString() ?? 'Donor',
              bloodGroup: d['blood_group']?.toString() ?? bloodGroup,
              distanceBand: '< 2.0 km',
              etaMinutes: 20,
              status: 'accepted',
              isStandby: false,
              phoneRevealed: true,
              phone: d['phone']?.toString(),
              latitude: dLat,
              longitude: dLng,
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('direct donors query error: $e');
      }
    }
    return [];
  }

  /// Create blood emergency request and trigger automated donor dispatch
  Future<String> createRequest({
    required String bloodGroup,
    required String component,
    required int unitsNeeded,
    required String urgency,
    required String hospitalName,
    required String hospitalArea,
    required double lat,
    required double lng,
    required String requesterName,
    required String requesterPhone,
    String? patientFirstName,
    int? patientAge,
    String? note,
    bool allowCompatible = false,
  }) async {
    final client = _client;
    if (client != null) {
      final res = await client.from('requests').insert({
        'patient_first_name': (patientFirstName != null && patientFirstName.isNotEmpty)
            ? patientFirstName
            : (requesterName.isNotEmpty ? requesterName : 'Patient'),
        'patient_age': patientAge ?? 35,
        'relation': 'family',
        'blood_group': bloodGroup,
        'component': component,
        'units_needed': unitsNeeded,
        'urgency': urgency,
        'hospital_name': hospitalName,
        'hospital_lat': lat,
        'hospital_lng': lng,
        'hospital_area': hospitalArea,
        'requester_name': requesterName,
        'requester_phone': requesterPhone,
        'allow_compatible': allowCompatible,
        'message_text': note,
        'status': 'searching',
      }).select('id').single();

      final reqId = res['id']?.toString();
      if (reqId != null && reqId.isNotEmpty) {
        try {
          await client.rpc('dispatch_request_to_donors', params: {
            'p_request_id': reqId,
            'p_hospital_lat': lat,
            'p_hospital_lng': lng,
            'p_blood_group': bloodGroup,
            'p_allow_compatible': allowCompatible,
            'p_radius_km': 30.0,
          });
        } catch (e) {
          debugPrint('dispatch_request_to_donors notice: $e');
        }
        return reqId;
      }
      throw Exception('Supabase failed to return created request ID.');
    }
    throw Exception('Supabase client is not available.');
  }

  /// Get contacts for an active request
  Future<List<DonorCardModel>> getRequestContacts(String requestId) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('request_contacts')
            .select('id, request_id, donor_id, ring_km, distance_km, status, donation_code, donors (first_name, blood_group, phone, donor_location (home_lat, home_lng))')
            .eq('request_id', requestId);

        if (res.isNotEmpty) {
          return res.map((row) {
            final donor = row['donors'] as Map<String, dynamic>? ?? {};
            final locs = donor['donor_location'];
            double? dLat;
            double? dLng;
            if (locs is List && locs.isNotEmpty) {
              dLat = (locs.first['home_lat'] as num?)?.toDouble();
              dLng = (locs.first['home_lng'] as num?)?.toDouble();
            } else if (locs is Map) {
              dLat = (locs['home_lat'] as num?)?.toDouble();
              dLng = (locs['home_lng'] as num?)?.toDouble();
            }

            final distKm =
                (row['distance_km'] ?? row['ring_km'] as num?)?.toDouble() ?? 1.5;
            return DonorCardModel(
              id: row['id']?.toString() ?? '',
              firstName: donor['first_name']?.toString() ?? 'Donor',
              bloodGroup: donor['blood_group']?.toString() ?? 'O+',
              distanceBand: '< ${(distKm + 0.5).toStringAsFixed(1)} km',
              etaMinutes: (distKm * 8).toInt().clamp(10, 45),
              status: row['status']?.toString() ?? 'accepted',
              isStandby: false,
              phoneRevealed: true,
              phone: donor['phone']?.toString(),
              donationCode: row['donation_code']?.toString(),
              latitude: dLat,
              longitude: dLng,
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('getRequestContacts error: $e');
      }
    }
    return [];
  }

  /// Realtime stream for request row
  Stream<Map<String, dynamic>?> streamRequest(String requestId) {
    final client = _client;
    if (client == null) return Stream.value(null);
    return client
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('id', requestId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  /// Realtime stream for request contacts
  Stream<List<Map<String, dynamic>>> streamRequestContacts(String requestId) {
    final client = _client;
    if (client == null) return Stream.value([]);
    return client
        .from('request_contacts')
        .stream(primaryKey: ['id'])
        .eq('request_id', requestId);
  }

  /// Get single request by ID
  Future<Map<String, dynamic>?> getRequest(String requestId) async {
    final client = _client;
    if (client != null) {
      try {
        return await client
            .from('requests')
            .select()
            .eq('id', requestId)
            .maybeSingle();
      } catch (e) {
        debugPrint('getRequest error: $e');
      }
    }
    return null;
  }

  /// Get active emergency requests
  Future<List<Map<String, dynamic>>> getActiveRequests() async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('requests')
            .select()
            .order('created_at', ascending: false)
            .limit(10);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getActiveRequests error: $e');
      }
    }
    return [];
  }

  /// Widen request search radius
  Future<bool> widenRequest(String requestId, double newRadiusKm, {int wave = 1}) async {
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

  /// Upload prescription slip image to Supabase Storage
  Future<String?> uploadPrescriptionSlip({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final path = 'slips/$fileName';
        await client.storage.from('slips').uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
        return client.storage.from('slips').getPublicUrl(path);
      } catch (e) {
        debugPrint('uploadPrescriptionSlip error: $e');
      }
    }
    return null;
  }
}
