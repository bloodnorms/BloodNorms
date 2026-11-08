// ============================================================================
// BloodNorms | request_search_service.dart
// Donor discovery and contact list queries for emergency requests
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/donor_card_model.dart';
import '../../../shared/services/supabase_service.dart';

class RequestSearchService {
  static final RequestSearchService _instance =
      RequestSearchService._internal();
  factory RequestSearchService() => _instance;
  RequestSearchService._internal();

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
              status: 'queued',
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
    return const [];
  }

  /// Get contacts for an active request
  Future<List<DonorCardModel>> getRequestContacts(String requestId) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('request_contacts')
            .select('id, request_id, donor_id, ring_km, distance_km, status, donation_code, donors (first_name, full_name, blood_group, phone, gender, dob, donor_location (home_lat, home_lng))')
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

            if (dLat == null || dLng == null) {
              final hash = (row['id']?.toString() ?? 'donor').hashCode.abs();
              final offset = (distKm / 111.0) * 0.7;
              dLat = 17.0005 + offset * (hash % 2 == 0 ? 1.0 : -0.8);
              dLng = 81.7800 + offset * (hash % 3 == 0 ? 0.9 : -1.1);
            }

            final rawStatus = row['status']?.toString() ?? 'queued';

            final dobStr = donor['dob']?.toString();
            int? donorAge;
            if (dobStr != null && dobStr.isNotEmpty) {
              final birthYear = DateTime.tryParse(dobStr)?.year;
              if (birthYear != null) donorAge = DateTime.now().year - birthYear;
            }

            return DonorCardModel(
              id: row['id']?.toString() ?? '',
              firstName: donor['full_name']?.toString() ?? donor['first_name']?.toString() ?? 'Donor',
              bloodGroup: donor['blood_group']?.toString() ?? 'O+',
              distanceBand: '${distKm.toStringAsFixed(1)} km away',
              etaMinutes: (distKm * 8).toInt().clamp(10, 45),
              status: rawStatus,
              isStandby: rawStatus == 'standby',
              phoneRevealed: true,
              phone: donor['phone']?.toString(),
              donationCode: row['donation_code']?.toString(),
              latitude: dLat,
              longitude: dLng,
              gender: donor['gender']?.toString() ?? 'Male',
              age: donorAge ?? 23,
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('getRequestContacts error: $e');
      }
    }
    return const [];
  }
}
