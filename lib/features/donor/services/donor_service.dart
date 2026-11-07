// ============================================================================
// BloodNorms | donor_service.dart
// Donor operations: registration, alert handling, history, and preferences
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/request_alert_model.dart';
import '../../../shared/services/supabase_service.dart';

class DonorService {
  static final DonorService _instance = DonorService._internal();
  factory DonorService() => _instance;
  DonorService._internal();

  SupabaseClient? get _client => SupabaseService().client;

  /// Register donor profile into Supabase
  Future<String?> registerDonor({
    required String fullName,
    required String phone,
    required String bloodGroup,
    required String gender,
    required DateTime dob,
    required double weightKg,
    required double lat,
    required double lng,
    String? area,
    String? city,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final donorRes = await client.from('donors').insert({
          'full_name': fullName,
          'first_name': fullName.split(' ').first,
          'phone': phone,
          'blood_group': bloodGroup,
          'gender': gender.toLowerCase(),
          'dob':
              '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}',
          'weight_kg': weightKg,
          'state': 'active',
          'trust_level': 1,
        }).select('id').single();

        final donorId = donorRes['id']?.toString();
        if (donorId != null) {
          await client.from('donor_location').insert({
            'donor_id': donorId,
            'home_lat': lat,
            'home_lng': lng,
            'area': area ?? 'Danavaipeta',
            'city': city ?? AppConstants.pilotCity,
          });
          return donorId;
        }
      } catch (e) {
        debugPrint('registerDonor error: $e');
      }
    }
    return null;
  }

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

  /// Get single donor profile by ID
  Future<Map<String, dynamic>?> getDonor(String donorId) async {
    final client = _client;
    if (client != null) {
      try {
        return await client
            .from('donors')
            .select('*, donor_location(*)')
            .eq('id', donorId)
            .maybeSingle();
      } catch (e) {
        debugPrint('getDonor error: $e');
      }
    }
    return null;
  }

  /// Get donors list with local fallback
  Future<List<Map<String, dynamic>>> getAllDonors() async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('donors')
            .select('id, full_name, phone, blood_group, state, total_donations, travel_radius_km, city, created_at')
            .order('created_at', ascending: false)
            .limit(20);
        if (res.isNotEmpty) return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getAllDonors error: $e');
      }
    }
    return [
      {'id': 'dn-001', 'full_name': 'Ravi Teja Varma', 'phone': '+91 98480 12345', 'blood_group': 'O+', 'state': 'active', 'total_donations': 4, 'travel_radius_km': 15, 'city': 'Rajahmundry', 'created_at': DateTime.now().subtract(const Duration(days: 45)).toIso8601String()},
      {'id': 'dn-002', 'full_name': 'Ananya Krishna', 'phone': '+91 94401 56789', 'blood_group': 'A-', 'state': 'active', 'total_donations': 2, 'travel_radius_km': 10, 'city': 'Rajahmundry', 'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String()},
      {'id': 'dn-003', 'full_name': 'K. Suresh Kumar', 'phone': '+91 98660 98765', 'blood_group': 'B+', 'state': 'paused', 'total_donations': 6, 'travel_radius_km': 25, 'city': 'Kakinada', 'created_at': DateTime.now().subtract(const Duration(days: 90)).toIso8601String()},
      {'id': 'dn-004', 'full_name': 'Deepika Reddy', 'phone': '+91 88324 11223', 'blood_group': 'AB+', 'state': 'active', 'total_donations': 1, 'travel_radius_km': 5, 'city': 'Rajahmundry', 'created_at': DateTime.now().subtract(const Duration(days: 12)).toIso8601String()},
    ];
  }

  /// Get donors expected at blood banks
  Future<List<Map<String, dynamic>>> getExpectedDonors() async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('request_contacts')
            .select('id, request_id, status, donation_code, ring_km, created_at, donors(first_name, full_name, blood_group, phone)')
            .inFilter('status', ['accepted', 'dispatched'])
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getExpectedDonors error: $e');
      }
    }
    return [];
  }

  /// Update donor active / paused state
  Future<bool> updateDonorState(String donorId, String state) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('donors').update({'state': state}).eq('id', donorId);
        return true;
      } catch (e) {
        debugPrint('updateDonorState error: $e');
      }
    }
    return false;
  }

  /// Delete donor account (DPDP compliance)
  Future<bool> deleteDonor(String donorId) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('donor_location').delete().eq('donor_id', donorId);
        await client.from('camp_signups').delete().eq('donor_id', donorId);
        await client.from('donors').delete().eq('id', donorId);
        return true;
      } catch (e) {
        debugPrint('deleteDonor error: $e');
      }
    }
    return false;
  }

  /// Update donor location and away preferences
  Future<bool> updateDonorLocationPreferences({
    required String donorId,
    required String city,
    required String area,
    required double travelRadiusKm,
    required bool isAway,
    String? awayReason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('donor_city_$donorId', city);
    await prefs.setString('donor_area_$donorId', area);
    await prefs.setDouble('donor_travel_radius_$donorId', travelRadiusKm);
    await prefs.setBool('donor_is_away_$donorId', isAway);
    if (awayReason != null) {
      await prefs.setString('donor_away_reason_$donorId', awayReason);
    }

    final client = _client;
    if (client != null) {
      try {
        await client.from('donors').update({
          'city': city,
          'area': area,
          'travel_radius_km': travelRadiusKm,
          'is_away': isAway,
          'away_reason': awayReason,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', donorId);
      } catch (e) {
        debugPrint('updateDonorLocationPreferences error: $e');
      }
    }
    return true;
  }

  /// Read donor location and away preferences
  Future<Map<String, dynamic>> getDonorLocationPreferences(String donorId) async {
    final prefs = await SharedPreferences.getInstance();
    final localCity = prefs.getString('donor_city_$donorId');
    final localArea = prefs.getString('donor_area_$donorId');
    final localRadius = prefs.getDouble('donor_travel_radius_$donorId');
    final localIsAway = prefs.getBool('donor_is_away_$donorId');
    final localReason = prefs.getString('donor_away_reason_$donorId');

    if (localCity != null) {
      return {
        'city': localCity,
        'area': localArea ?? 'Danavaipeta',
        'travel_radius_km': localRadius ?? 15.0,
        'is_away': localIsAway ?? false,
        'away_reason': localReason,
      };
    }

    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('donors')
            .select('city, area, travel_radius_km, is_away, away_reason')
            .eq('id', donorId)
            .maybeSingle();
        if (res != null) {
          return {
            'city': res['city']?.toString() ?? 'Rajahmundry',
            'area': res['area']?.toString() ?? 'Danavaipeta',
            'travel_radius_km':
                (res['travel_radius_km'] as num?)?.toDouble() ?? 15.0,
            'is_away': res['is_away'] == true,
            'away_reason': res['away_reason']?.toString(),
          };
        }
      } catch (_) {}
    }

    return {
      'city': 'Rajahmundry',
      'area': 'Danavaipeta',
      'travel_radius_km': 15.0,
      'is_away': false,
      'away_reason': null,
    };
  }
}
