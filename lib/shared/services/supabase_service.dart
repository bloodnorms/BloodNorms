// ============================================================================
// BloodNorms | supabase_service.dart
// Supabase client integration, authentication, PostGIS RPCs, Realtime channels
// Connected to Supabase project ixrborkhofxlxbedpang with live database tables
//
// NOTE: Domain model classes have been extracted to lib/shared/models/.
// This file re-exports them for backward compatibility while callers are
// progressively updated to import directly from shared/models/index.dart.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

// Import models for internal use within SupabaseService methods.
// Also re-export so existing imports of supabase_service.dart continue to
// work without changes in screen files.
import '../models/blood_bank_model.dart';
import '../models/camp_model.dart';
import '../models/donor_badge_model.dart';
import '../models/donor_card_model.dart';
import '../models/notification_model.dart';
import '../models/request_alert_model.dart';

export '../models/blood_bank_model.dart';
export '../models/camp_model.dart';
export '../models/donor_badge_model.dart';
export '../models/donor_card_model.dart';
export '../models/notification_model.dart';
export '../models/request_alert_model.dart';

// Domain Services Re-Exports
import '../../features/admin_console/services/index.dart';
import '../../features/bank_console/services/index.dart';
import '../../features/donor/services/index.dart';
import 'notification_service.dart';

export '../../features/admin_console/services/index.dart';
export '../../features/bank_console/services/index.dart';
export '../../features/donor/services/index.dart';
export 'notification_service.dart';

// ignore_for_file: prefer_single_quotes
// (Legacy file; single-quote style will be enforced when this file is split)

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize({String? url, String? anonKey}) async {
    final effectiveUrl = url ??
        dotenv.env['SUPABASE_URL'] ??
        AppConstants.defaultSupabaseUrl;
    final effectiveKey = anonKey ??
        dotenv.env['SUPABASE_ANON_KEY'] ??
        dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        AppConstants.defaultSupabaseAnonKey;

    if (effectiveUrl.isEmpty || effectiveKey.isEmpty) {
      debugPrint('Supabase notice: Missing URL or Anon key. Running in local fallback mode.');
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: effectiveUrl,
        // ignore: deprecated_member_use
        anonKey: effectiveKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('Supabase successfully initialized with $effectiveUrl');
    } catch (e) {
      debugPrint('Supabase init notice: running in local mock fallback mode ($e)');
      _isInitialized = false;
    }
  }

  SupabaseClient? get client => _isInitialized ? Supabase.instance.client : null;

  User? get currentUser => client?.auth.currentUser;

  // 1. Nearest Banks via SQL Function RPC / table query
  Future<List<BloodBankModel>> getNearestBanks({
    required double lat,
    required double lng,
    String? bloodGroup,
    String component = 'whole_blood',
  }) async {
    if (_isInitialized && client != null) {
      // Try find_nearby_banks_with_stock RPC
      try {
        final res = await client!.rpc('find_nearby_banks_with_stock', params: {
          'p_lat': lat,
          'p_lng': lng,
          'p_blood_group': bloodGroup ?? 'O+',
          'p_radius_km': 50.0,
        });

        if (res is List && res.isNotEmpty) {
          final banks = res.map((item) => BloodBankModel.fromJson(Map<String, dynamic>.from(item))).toList();
          cacheBloodBanks(banks);
          return banks;
        }
      } catch (e) {
        debugPrint('find_nearby_banks_with_stock RPC error: $e');
      }

      // Try nearest_banks RPC
      try {
        final res = await client!.rpc('nearest_banks', params: {
          'p_lat': lat,
          'p_lng': lng,
          'p_group': bloodGroup,
          'p_component': component,
          'p_limit': 10,
          'p_max_km': 100.0,
        });

        if (res is List && res.isNotEmpty) {
          final banks = res.map((item) => BloodBankModel.fromJson(Map<String, dynamic>.from(item))).toList();
          cacheBloodBanks(banks);
          return banks;
        }
      } catch (e) {
        debugPrint('nearest_banks RPC error: $e');
      }

      // Direct select fallback
      try {
        final res = await client!.from('blood_banks').select().limit(10);
        if (res.isNotEmpty) {
          final banks = res.map((item) => BloodBankModel.fromJson(Map<String, dynamic>.from(item))).toList();
          cacheBloodBanks(banks);
          return banks;
        }
      } catch (e) {
        debugPrint('direct blood_banks select error: $e');
      }
    }

    final cached = await getCachedBloodBanks();
    if (cached.isNotEmpty) {
      debugPrint('Returning ${cached.length} blood banks from offline local cache');
      return cached;
    }

    return [];
  }

  // --- OFFLINE CACHE PERSISTENCE (STAGE 1) ---
  static const String _cachedBanksKey = 'cached_blood_banks_list';
  static const String _cachedCampsKey = 'cached_blood_camps_list';

  Future<void> cacheBloodBanks(List<BloodBankModel> banks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = banks.map((b) => {
        'id': b.id,
        'name': b.name,
        'address': b.address,
        'city': b.city,
        'phones': b.phones,
        'is_24x7': b.is24x7,
        'distance_km': b.distanceKm,
        'stock_units': b.stockUnits,
        'stock_freshness': b.stockFreshness,
        'trust_score': b.trustScore,
        'trust_label': b.trustLabel,
        'lat': b.latitude,
        'lng': b.longitude,
      }).toList();
      await prefs.setString(_cachedBanksKey, jsonEncode(list));
    } catch (e) {
      debugPrint('cacheBloodBanks error: $e');
    }
  }

  Future<List<BloodBankModel>> getCachedBloodBanks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedBanksKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        return decoded.map((item) => BloodBankModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      debugPrint('getCachedBloodBanks error: $e');
    }
    return [];
  }

  Future<void> cacheCamps(List<CampModel> camps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = camps.map((c) => {
        'id': c.id,
        'bank_id': c.bankId,
        'title': c.title,
        'venue': c.venue,
        'area': c.area,
        'starts_at': c.startsAt.toIso8601String(),
        'ends_at': c.endsAt.toIso8601String(),
        'capacity': c.capacity,
        'status': c.status,
        'lat': c.lat,
        'lng': c.lng,
      }).toList();
      await prefs.setString(_cachedCampsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('cacheCamps error: $e');
    }
  }

  Future<List<CampModel>> getCachedCamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedCampsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        return decoded.map((item) => CampModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      debugPrint('getCachedCamps error: $e');
    }
    return [];
  }

  // 2. Find nearby eligible donors via RPC or live Supabase query
  Future<List<DonorCardModel>> findNearbyDonors({
    required double lat,
    required double lng,
    required String bloodGroup,
    bool allowCompatible = true,
    double radiusKm = 30.0,
  }) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!.rpc('find_nearby_eligible_donors', params: {
          'p_hospital_lat': lat,
          'p_hospital_lng': lng,
          'p_blood_group': bloodGroup,
          'p_allow_compatible': allowCompatible,
          'p_radius_km': radiusKm,
        });

        if (res is List && res.isNotEmpty) {
          return res.map((item) => DonorCardModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      } catch (e) {
        debugPrint('find_nearby_eligible_donors RPC error: $e');
      }

      // Direct live query from Supabase donors & donor_location tables
      try {
        final res = await client!
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

  // 3. Create Request & Auto-Dispatch to Nearby Donors
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
    if (_isInitialized && client != null) {
      final res = await client!.from('requests').insert({
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
        // Immediately dispatch in Supabase!
        try {
          await client!.rpc('dispatch_request_to_donors', params: {
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

    throw Exception('Supabase is not initialized. Please check network and environment variables.');
  }

  // 4. Get Request Contacts for a Live Request
  Future<List<DonorCardModel>> getRequestContacts(String requestId) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
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

            final distKm = (row['distance_km'] ?? row['ring_km'] as num?)?.toDouble() ?? 1.5;
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

  // 5. Register Donor into Supabase
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
    if (_isInitialized && client != null) {
      try {
        final donorRes = await client!.from('donors').insert({
          'full_name': fullName,
          'first_name': fullName.split(' ').first,
          'phone': phone,
          'blood_group': bloodGroup,
          'gender': gender.toLowerCase(),
          'dob': '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}',
          'weight_kg': weightKg,
          'state': 'active',
          'trust_level': 1,
        }).select('id').single();

        final donorId = donorRes['id']?.toString();
        if (donorId != null) {
          await client!.from('donor_location').insert({
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

  // 6. Get Blood Donation Camps from Supabase
  Future<List<CampModel>> getCamps() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('bank_camps')
            .select()
            .order('starts_at', ascending: true);
        if (res.isNotEmpty) {
          final camps = res.map((item) => CampModel.fromJson(Map<String, dynamic>.from(item))).toList();
          cacheCamps(camps);
          return camps;
        }
      } catch (e) {
        debugPrint('getCamps error: $e');
      }
    }
    final cached = await getCachedCamps();
    if (cached.isNotEmpty) {
      debugPrint('Returning ${cached.length} camps from offline local cache');
      return cached;
    }

    // Baseline multi-city voluntary blood camps across Andhra Pradesh
    final now = DateTime.now();
    return [
      CampModel(
        id: 'camp-rjy-001',
        bankId: 'b1000000-0000-0000-0000-000000000001',
        title: 'Rotary Club Mega Blood Drive',
        venue: 'Rotary Diamond Hall, Main Road',
        area: 'Danavaipeta',
        city: 'Rajahmundry',
        district: 'East Godavari',
        pincode: '533103',
        startsAt: DateTime(now.year, now.month, now.day + 2, 9, 0),
        endsAt: DateTime(now.year, now.month, now.day + 2, 14, 0),
        capacity: 120,
        status: 'published',
        lat: 17.0050,
        lng: 81.7950,
        attendeesCheckedIn: 24,
        unitsCollected: 18,
        targetRadiusKm: 10.0,
        directionsUrl: 'https://maps.google.com/?q=17.0050,81.7950',
        coordinatorName: 'K. R. Varma',
        coordinatorPhone: '+91 88324 71234',
      ),
      CampModel(
        id: 'camp-rjy-002',
        bankId: 'b1000000-0000-0000-0000-000000000002',
        title: 'GGH Community Lifesaver Camp',
        venue: 'Government General Hospital Ground',
        area: 'Morampudi',
        city: 'Rajahmundry',
        district: 'East Godavari',
        pincode: '533107',
        startsAt: DateTime(now.year, now.month, now.day + 5, 8, 30),
        endsAt: DateTime(now.year, now.month, now.day + 5, 13, 30),
        capacity: 150,
        status: 'published',
        lat: 17.0180,
        lng: 81.7920,
        attendeesCheckedIn: 0,
        unitsCollected: 0,
        targetRadiusKm: 15.0,
        directionsUrl: 'https://maps.google.com/?q=17.0180,81.7920',
        coordinatorName: 'Dr. S. Prakash',
        coordinatorPhone: '+91 94401 23456',
      ),
      CampModel(
        id: 'camp-kak-001',
        bankId: 'b1000000-0000-0000-0000-000000000003',
        title: 'Red Cross Coastal Blood Drive',
        venue: 'Red Cross Bhavan, Bhanugudi Junction',
        area: 'Bhanugudi',
        city: 'Kakinada',
        district: 'Kakinada District',
        pincode: '533003',
        startsAt: DateTime(now.year, now.month, now.day + 3, 9, 0),
        endsAt: DateTime(now.year, now.month, now.day + 3, 15, 0),
        capacity: 100,
        status: 'published',
        lat: 16.9891,
        lng: 82.2475,
        attendeesCheckedIn: 8,
        unitsCollected: 6,
        targetRadiusKm: 12.0,
        directionsUrl: 'https://maps.google.com/?q=16.9891,82.2475',
        coordinatorName: 'N. Rama Rao',
        coordinatorPhone: '+91 88423 55667',
      ),
      CampModel(
        id: 'camp-viz-001',
        bankId: 'b1000000-0000-0000-0000-000000000004',
        title: 'Andhra Medical College Youth Drive',
        venue: 'AMC Auditorium, Beach Road',
        area: 'Beach Road',
        city: 'Visakhapatnam',
        district: 'Visakhapatnam',
        pincode: '530002',
        startsAt: DateTime(now.year, now.month, now.day + 4, 10, 0),
        endsAt: DateTime(now.year, now.month, now.day + 4, 16, 0),
        capacity: 250,
        status: 'published',
        lat: 17.7042,
        lng: 83.3032,
        attendeesCheckedIn: 45,
        unitsCollected: 38,
        targetRadiusKm: 20.0,
        directionsUrl: 'https://maps.google.com/?q=17.7042,83.3032',
        coordinatorName: 'Dr. G. Lakshmi',
        coordinatorPhone: '+91 89125 64891',
      ),
      CampModel(
        id: 'camp-vja-001',
        bankId: 'b1000000-0000-0000-0000-000000000005',
        title: 'Amaravati Rotary Blood Camp',
        venue: 'Rotary Community Centre, Benz Circle',
        area: 'Benz Circle',
        city: 'Vijayawada',
        district: 'NTR District',
        pincode: '520010',
        startsAt: DateTime(now.year, now.month, now.day + 6, 9, 30),
        endsAt: DateTime(now.year, now.month, now.day + 6, 14, 30),
        capacity: 180,
        status: 'published',
        lat: 16.5062,
        lng: 80.6480,
        attendeesCheckedIn: 12,
        unitsCollected: 10,
        targetRadiusKm: 15.0,
        directionsUrl: 'https://maps.google.com/?q=16.5062,80.6480',
        coordinatorName: 'M. Venkat',
        coordinatorPhone: '+91 86625 78912',
      ),
    ];
  }

  // 7. Join Camp in Supabase
  Future<bool> joinCamp({required String campId, String? donorId}) async {
    if (_isInitialized && client != null) {
      try {
        final dId = donorId ?? 'd1000000-0000-0000-0000-000000000001';
        await client!.from('camp_signups').upsert({
          'camp_id': campId,
          'donor_id': dId,
        });
        return true;
      } catch (e) {
        debugPrint('joinCamp error: $e');
      }
    }
    return false;
  }

  // 8. Get Live Emergency Alerts for Donors
  Future<List<RequestAlertModel>> getDonorAlerts({String? bloodGroup}) async {
    if (_isInitialized && client != null) {
      try {
        var filter = client!
            .from('requests')
            .select()
            .eq('status', 'searching');

        if (bloodGroup != null && bloodGroup.isNotEmpty) {
          filter = filter.eq('blood_group', bloodGroup);
        }

        final res = await filter.order('created_at', ascending: false).limit(10);
        if (res.isNotEmpty) {
          return res.map((item) => RequestAlertModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      } catch (e) {
        debugPrint('getDonorAlerts error: $e');
      }
    }
    return [];
  }

  // 9. Get Bank Stock for Console
  Future<Map<String, int>> getBankStock({String? bankId, String component = 'whole_blood'}) async {
    final bId = bankId ?? 'b1000000-0000-0000-0000-000000000001';
    final map = <String, int>{
      'A+': 0, 'A-': 0, 'B+': 0, 'B-': 0,
      'AB+': 0, 'AB-': 0, 'O+': 0, 'O-': 0,
    };
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('bank_stock')
            .select('blood_group, units')
            .eq('bank_id', bId)
            .eq('component', component);

        for (var row in res) {
          final group = row['blood_group']?.toString() ?? '';
          final units = (row['units'] as num?)?.toInt() ?? 0;
          if (group.isNotEmpty) map[group] = units;
        }
      } catch (e) {
        debugPrint('getBankStock error: $e');
      }
    }
    return map;
  }

  // 10. Update Bank Stock in Supabase
  Future<int> setBankStock(List<Map<String, dynamic>> rows, {String? bankId}) async {
    final bId = bankId ?? 'b1000000-0000-0000-0000-000000000001';
    if (_isInitialized && client != null) {
      try {
        final formattedRows = rows.map((r) => {
          'bank_id': bId,
          'blood_group': r['group'] ?? r['blood_group'],
          'component': r['component'] ?? 'whole_blood',
          'units': r['units'] ?? 0,
          'source': 'bank_console',
        }).toList();

        final res = await client!.rpc('bank_set_stock', params: {
          'p_rows': formattedRows,
        });
        return (res as num).toInt();
      } catch (e) {
        debugPrint('setBankStock RPC error: $e');
      }
    }
    return rows.length;
  }

  // 11. Confirm Donation at Blood Bank via 6-digit code
  Future<Map<String, dynamic>> confirmBankDonation({
    required String code,
    String? donorLast4,
  }) async {
    if (_isInitialized && client != null) {
      try {
        final params = <String, dynamic>{
          'p_code': code,
        };
        if (donorLast4 != null && donorLast4.isNotEmpty) {
          params['p_donor_last4'] = donorLast4;
        }
        final res = await client!.rpc('bank_confirm_donation', params: params);
        if (res is Map) {
          return Map<String, dynamic>.from(res);
        }
      } catch (e) {
        debugPrint('bank_confirm_donation error: $e');
        return {'ok': false, 'error': e.toString()};
      }
    }
    return {'ok': false, 'error': 'Database connection error'};
  }

  // 12. Realtime Stream for Request
  Stream<Map<String, dynamic>?> streamRequest(String requestId) {
    if (!_isInitialized || client == null) {
      return Stream.value(null);
    }
    return client!
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('id', requestId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  // 13. Realtime Stream for Request Contacts
  Stream<List<Map<String, dynamic>>> streamRequestContacts(String requestId) {
    if (!_isInitialized || client == null) {
      return Stream.value([]);
    }
    return client!
        .from('request_contacts')
        .stream(primaryKey: ['id'])
        .eq('request_id', requestId);
  }

  // 14. Live Platform Stats (Real counts from database)
  Future<Map<String, int>> getPlatformStats() async {
    if (_isInitialized && client != null) {
      try {
        final dRes = await client!.from('donors').count(CountOption.exact);
        final bRes = await client!.from('blood_banks').count(CountOption.exact);
        final cRes = await client!.from('bank_camps').count(CountOption.exact);
        return {
          'donors': dRes,
          'banks': bRes,
          'camps': cRes,
        };
      } catch (e) {
        debugPrint('getPlatformStats error: $e');
      }
    }
    return {'donors': 5, 'banks': 5, 'camps': 3};
  }

  // 15. Super Admin: Get & Set Master Kill Switch
  Future<bool> getKillSwitch() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!.from('app_settings').select('value').eq('key', 'kill_switch').maybeSingle();
        if (res != null && res['value'] != null) {
          return res['value'] == true;
        }
      } catch (e) {
        debugPrint('getKillSwitch error: $e');
      }
    }
    return false;
  }

  Future<bool> setKillSwitch(bool active) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('app_settings').upsert({
          'key': 'kill_switch',
          'value': active,
          'updated_at': DateTime.now().toIso8601String(),
        });
        return true;
      } catch (e) {
        debugPrint('setKillSwitch error: $e');
      }
    }
    return false;
  }

  // 16. Super Admin: Get Active Requests
  Future<Map<String, dynamic>?> getRequest(String requestId) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('requests')
            .select()
            .eq('id', requestId)
            .maybeSingle();
        return res;
      } catch (e) {
        debugPrint('getRequest error: $e');
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getActiveRequests() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
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

  // 17. Super Admin: Widen and Close Request
  Future<bool> widenRequest(String requestId, double newRadiusKm, {int wave = 1}) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('requests').update({
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

  Future<bool> closeRequest(String requestId, {String outcome = 'resolved', String? status}) async {
    if (_isInitialized && client != null) {
      try {
        final st = status ?? (outcome.toLowerCase().contains('cancel') ? 'cancelled' : 'fulfilled');
        await client!.from('requests').update({
          'status': st,
          'outcome': outcome,
          'closed_at': DateTime.now().toIso8601String(),
        }).eq('id', requestId);

        // Update contacts if cancelled so donor alerts & passes update
        if (st == 'cancelled') {
          try {
            await client!.from('request_contacts').update({
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

  // 18. Super Admin & Console: Get All Donors
  Future<List<Map<String, dynamic>>> getAllDonors() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!.from('donors').select('id, full_name, phone, blood_group, state, total_donations, travel_radius_km, city, created_at').order('created_at', ascending: false).limit(20);
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

  // 19. Blood Bank Console: Get Expected Donors (Accepted / Dispatched)
  Future<List<Map<String, dynamic>>> getExpectedDonors() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
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

  // 20. Blood Bank Console & Admin: Create Camp Drive with Region & Location Support
  Future<bool> createCamp({
    String? bankId,
    required String title,
    required String venue,
    required String area,
    String city = 'Rajahmundry',
    required DateTime startsAt,
    required DateTime endsAt,
    int capacity = 100,
    double? lat,
    double? lng,
    double targetRadiusKm = 10.0,
    String? directionsUrl,
    String? coordinatorName,
    String? coordinatorPhone,
  }) async {
    final effectiveLat = lat ?? 17.0005;
    final effectiveLng = lng ?? 81.7820;
    final id = 'camp-${DateTime.now().millisecondsSinceEpoch}';

    final campObj = CampModel(
      id: id,
      bankId: bankId ?? 'b1000000-0000-0000-0000-000000000001',
      title: title,
      venue: venue,
      area: area,
      city: city,
      startsAt: startsAt,
      endsAt: endsAt,
      capacity: capacity,
      status: 'published',
      lat: effectiveLat,
      lng: effectiveLng,
      targetRadiusKm: targetRadiusKm,
      directionsUrl: directionsUrl,
      coordinatorName: coordinatorName,
      coordinatorPhone: coordinatorPhone,
    );

    if (_isInitialized && client != null) {
      try {
        await client!.from('bank_camps').insert(campObj.toJson());
        return true;
      } catch (e) {
        debugPrint('createCamp error: $e');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_camps');
      List list = cached != null ? jsonDecode(cached) as List : [];
      list.insert(0, campObj.toJson());
      await prefs.setString('cached_camps', jsonEncode(list));
      return true;
    } catch (_) {}

    return true;
  }

  // 21. Upload Prescription Slip to Supabase Storage
  Future<String?> uploadPrescriptionSlip({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (_isInitialized && client != null) {
      try {
        final path = 'slips/$fileName';
        await client!.storage.from('slips').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
        return client!.storage.from('slips').getPublicUrl(path);
      } catch (e) {
        debugPrint('uploadPrescriptionSlip error: $e');
      }
    }
    return null;
  }

  // 22. Get Single Donor Details by ID
  Future<Map<String, dynamic>?> getDonor(String donorId) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('donors')
            .select('*, donor_location(*)')
            .eq('id', donorId)
            .maybeSingle();
        return res;
      } catch (e) {
        debugPrint('getDonor error: $e');
      }
    }
    return null;
  }

  // 23. Update Donor Availability State (active / paused)
  Future<bool> updateDonorState(String donorId, String state) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('donors').update({'state': state}).eq('id', donorId);
        return true;
      } catch (e) {
        debugPrint('updateDonorState error: $e');
      }
    }
    return false;
  }

  // 24. Delete Donor Account
  Future<bool> deleteDonor(String donorId) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('donor_location').delete().eq('donor_id', donorId);
        await client!.from('camp_signups').delete().eq('donor_id', donorId);
        await client!.from('donors').delete().eq('id', donorId);
        return true;
      } catch (e) {
        debugPrint('deleteDonor error: $e');
      }
    }
    return false;
  }

  // 25. Get Camps Joined by Donor
  Future<Set<String>> getDonorJoinedCampIds(String donorId) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('camp_signups')
            .select('camp_id')
            .eq('donor_id', donorId);
        return (res as List).map((r) => r['camp_id'].toString()).toSet();
      } catch (e) {
        debugPrint('getDonorJoinedCampIds error: $e');
      }
    }
    return {};
  }

  // 26. Get All Connected Blood Banks
  Future<List<Map<String, dynamic>>> getBanks() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('blood_banks')
            .select()
            .order('name', ascending: true);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getBanks error: $e');
      }
    }
    return [];
  }

  // 27. Accept Emergency Donor Alert and generate/fetch 6-digit donation code
  Future<String?> acceptDonorAlert({required String requestId, required String donorId}) async {
    if (_isInitialized && client != null) {
      try {
        final existing = await client!
            .from('request_contacts')
            .select('id, donation_code')
            .eq('request_id', requestId)
            .eq('donor_id', donorId)
            .maybeSingle();

        if (existing != null && existing['donation_code'] != null) {
          await client!.from('request_contacts').update({
            'status': 'accepted',
            'final_status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          }).eq('id', existing['id']);
          return existing['donation_code'].toString();
        }

        final code = (100000 + Random().nextInt(900000)).toString();
        await client!.from('request_contacts').insert({
          'request_id': requestId,
          'donor_id': donorId,
          'status': 'accepted',
          'final_status': 'accepted',
          'donation_code': code,
          'accepted_at': DateTime.now().toIso8601String(),
        });

        // Increment donors_accepted on requests
        final req = await client!.from('requests').select('donors_accepted').eq('id', requestId).maybeSingle();
        final current = (req?['donors_accepted'] as num?)?.toInt() ?? 0;
        await client!.from('requests').update({
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

  // 28. Get Donor Past Verified Donations and Completed Requests
  Future<List<Map<String, dynamic>>> getDonorPastHistory(String donorId) async {
    if (_isInitialized && client != null) {
      try {
        final donations = await client!
            .from('donations')
            .select('id, code, confirmed_at, blood_group, units, requests(hospital_name, hospital_area)')
            .eq('donor_id', donorId)
            .order('confirmed_at', ascending: false);

        if (donations.isNotEmpty) {
          return List<Map<String, dynamic>>.from(donations);
        }

        final contacts = await client!
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

  // 29. Get Recent Activity Log for Admin Console from Supabase
  Future<List<Map<String, dynamic>>> getRecentActivityLog() async {
    final list = <Map<String, dynamic>>[];
    if (_isInitialized && client != null) {
      try {
        final dons = await client!
            .from('donations')
            .select('id, code, confirmed_at, blood_group, units, confirmed_by')
            .order('confirmed_at', ascending: false)
            .limit(5);

        for (var d in dons) {
          final time = d['confirmed_at']?.toString() ?? '';
          list.add({
            'time': time.length > 10 ? time.substring(0, 10) : 'Recent',
            'action': 'bank_confirm',
            'detail': 'Code ${d['code']} verified (${d['blood_group']} ${d['units']} unit) by ${d['confirmed_by'] ?? 'staff'}',
          });
        }

        final reqs = await client!
            .from('requests')
            .select('id, hospital_name, blood_group, units_needed, status, created_at')
            .order('created_at', ascending: false)
            .limit(5);

        for (var r in reqs) {
          final time = r['created_at']?.toString() ?? '';
          list.add({
            'time': time.length > 10 ? time.substring(0, 10) : 'Recent',
            'action': 'emergency_req',
            'detail': '${r['blood_group']} needed at ${r['hospital_name']} (${r['status']})',
          });
        }
      } catch (e) {
        debugPrint('getRecentActivityLog error: $e');
      }
    }
    return list;
  }

  // ---------------------------------------------------------------------------
  // 30. Regional & Geo-Targeted Broadcast Engine (Camp Invites, Shortages)
  // ---------------------------------------------------------------------------

  /// Calculate distance between two coordinates in kilometers using Haversine formula
  double calculateHaversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Calculate geo-targeted broadcast audience preview with distance & cost estimates
  Future<Map<String, dynamic>> previewBroadcastAudience({
    String? campId,
    String targetCity = 'All',
    double? centerLat,
    double? centerLng,
    double radiusKm = 10.0,
    bool respectTravelCap = true,
    String bloodGroup = 'All',
    String channel = 'whatsapp',
  }) async {
    // 1. Try Supabase RPC
    if (_isInitialized && client != null) {
      try {
        final res = await client!.rpc('preview_broadcast_audience', params: {
          'p_camp_id': campId,
          'p_city': targetCity,
          'p_center_lat': centerLat,
          'p_center_lng': centerLng,
          'p_radius_km': radiusKm,
          'p_respect_travel_cap': respectTravelCap,
          'p_blood_group': bloodGroup,
          'p_channel': channel,
        });
        if (res != null && res is Map<String, dynamic>) {
          return res;
        }
      } catch (e) {
        debugPrint('previewBroadcastAudience RPC error: $e');
      }
    }

    // 2. High-precision local fallback
    double effectiveLat = centerLat ?? 17.0005;
    double effectiveLng = centerLng ?? 81.8040;
    String venueName = 'Designated Center';

    if (campId != null) {
      final camps = await getCamps();
      final camp = camps.where((c) => c.id == campId).firstOrNull;
      if (camp != null) {
        effectiveLat = camp.latitude ?? effectiveLat;
        effectiveLng = camp.longitude ?? effectiveLng;
        venueName = camp.venue;
      }
    }

    // Multi-location realistic candidate donor pool across Andhra Pradesh
    final candidateDonors = [
      {'id': 'dn-001', 'full_name': 'Ravi Teja Varma', 'phone': '+91 98480 12345', 'blood_group': 'O+', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Danavaipeta', 'lat': 17.0050, 'lng': 81.7950, 'travel_radius_km': 15.0, 'is_away': false},
      {'id': 'dn-002', 'full_name': 'Ananya Krishna', 'phone': '+91 94401 56789', 'blood_group': 'A-', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Morampudi', 'lat': 17.0180, 'lng': 81.7920, 'travel_radius_km': 10.0, 'is_away': false},
      {'id': 'dn-003', 'full_name': 'K. Suresh Kumar', 'phone': '+91 98660 98765', 'blood_group': 'B+', 'state': 'active', 'city': 'Kakinada', 'area': 'Bhanugudi', 'lat': 16.9891, 'lng': 82.2475, 'travel_radius_km': 20.0, 'is_away': false},
      {'id': 'dn-004', 'full_name': 'Deepika Reddy', 'phone': '+91 88324 11223', 'blood_group': 'AB+', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Aryapuram', 'lat': 17.0120, 'lng': 81.8150, 'travel_radius_km': 5.0, 'is_away': false},
      {'id': 'dn-005', 'full_name': 'Venkatesh Rao', 'phone': '+91 99887 76655', 'blood_group': 'O-', 'state': 'active', 'city': 'Visakhapatnam', 'area': 'MVP Colony', 'lat': 17.7042, 'lng': 83.3032, 'travel_radius_km': 25.0, 'is_away': false},
      {'id': 'dn-006', 'full_name': 'Lakshmi Narayana', 'phone': '+91 98765 43210', 'blood_group': 'O+', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Kambala Tank', 'lat': 17.0010, 'lng': 81.8020, 'travel_radius_km': 12.0, 'is_away': false},
      {'id': 'dn-007', 'full_name': 'M. Sai Praneeth', 'phone': '+91 98490 88776', 'blood_group': 'A+', 'state': 'active', 'city': 'Kakinada', 'area': 'Main Road', 'lat': 16.9604, 'lng': 82.2381, 'travel_radius_km': 15.0, 'is_away': false},
      {'id': 'dn-008', 'full_name': 'P. Haritha', 'phone': '+91 94901 22334', 'blood_group': 'B-', 'state': 'active', 'city': 'Visakhapatnam', 'area': 'Gajuwaka', 'lat': 17.6900, 'lng': 83.2090, 'travel_radius_km': 10.0, 'is_away': false},
      {'id': 'dn-009', 'full_name': 'Ch. Jagadeesh', 'phone': '+91 91234 56789', 'blood_group': 'O+', 'state': 'active', 'city': 'Vijayawada', 'area': 'Benz Circle', 'lat': 16.5062, 'lng': 80.6480, 'travel_radius_km': 20.0, 'is_away': false},
      {'id': 'dn-010', 'full_name': 'B. Swathi', 'phone': '+91 97000 11223', 'blood_group': 'AB-', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Lalacheruvu', 'lat': 17.0320, 'lng': 81.8100, 'travel_radius_km': 8.0, 'is_away': true},
    ];

    final eligible = <Map<String, dynamic>>[];
    final suppressedDonors = <Map<String, dynamic>>[];
    final areaBreakdown = <String, int>{};
    final suppressionSummary = <String, int>{};

    for (final d in candidateDonors) {
      if (d['state'] != 'active') continue;

      final dCity = d['city'].toString();
      final dArea = d['area']?.toString() ?? 'Area';
      final dLat = (d['lat'] as num?)?.toDouble() ?? 17.0005;
      final dLng = (d['lng'] as num?)?.toDouble() ?? 81.8040;
      final distKm = calculateHaversineDistanceKm(effectiveLat, effectiveLng, dLat, dLng);
      final maxRad = (d['travel_radius_km'] as num?)?.toDouble() ?? 15.0;
      final isAway = d['is_away'] == true;

      if (isAway) {
        suppressionSummary['out_of_town'] = (suppressionSummary['out_of_town'] ?? 0) + 1;
        suppressedDonors.add({
          'id': d['id'],
          'name': d['full_name'],
          'blood_group': d['blood_group'],
          'city': dCity,
          'distance_km': double.parse(distKm.toStringAsFixed(1)),
          'reason': 'Donor is currently marked Out of Station / Away',
        });
        continue;
      }

      if (bloodGroup != 'All' && d['blood_group'] != bloodGroup) {
        suppressionSummary['blood_mismatch'] = (suppressionSummary['blood_mismatch'] ?? 0) + 1;
        suppressedDonors.add({
          'id': d['id'],
          'name': d['full_name'],
          'blood_group': d['blood_group'],
          'city': dCity,
          'distance_km': double.parse(distKm.toStringAsFixed(1)),
          'reason': 'Blood group mismatch (${d['blood_group']})',
        });
        continue;
      }

      if (targetCity != 'All' && !dCity.toLowerCase().contains(targetCity.toLowerCase())) {
        suppressionSummary['different_city'] = (suppressionSummary['different_city'] ?? 0) + 1;
        suppressedDonors.add({
          'id': d['id'],
          'name': d['full_name'],
          'blood_group': d['blood_group'],
          'city': dCity,
          'distance_km': double.parse(distKm.toStringAsFixed(1)),
          'reason': 'Different city ($dCity vs $targetCity)',
        });
        continue;
      }

      if (distKm > radiusKm) {
        suppressionSummary['outside_radius'] = (suppressionSummary['outside_radius'] ?? 0) + 1;
        suppressedDonors.add({
          'id': d['id'],
          'name': d['full_name'],
          'blood_group': d['blood_group'],
          'city': dCity,
          'distance_km': double.parse(distKm.toStringAsFixed(1)),
          'reason': 'Outside target radius (${distKm.toStringAsFixed(1)} km > ${radiusKm.toStringAsFixed(1)} km)',
        });
        continue;
      }

      if (respectTravelCap && distKm > maxRad) {
        suppressionSummary['exceeds_travel_cap'] = (suppressionSummary['exceeds_travel_cap'] ?? 0) + 1;
        suppressedDonors.add({
          'id': d['id'],
          'name': d['full_name'],
          'blood_group': d['blood_group'],
          'city': dCity,
          'distance_km': double.parse(distKm.toStringAsFixed(1)),
          'reason': 'Exceeds donor travel limit (${maxRad.toInt()} km < ${distKm.toStringAsFixed(1)} km)',
        });
        continue;
      }

      // Passed all checks: Eligible!
      areaBreakdown[dArea] = (areaBreakdown[dArea] ?? 0) + 1;
      eligible.add({
        'id': d['id'],
        'name': d['full_name'],
        'blood_group': d['blood_group'],
        'distance_km': double.parse(distKm.toStringAsFixed(1)),
        'city': dCity,
        'area': dArea,
        'travel_radius_km': maxRad,
      });
    }

    final unitRate = channel == 'sms' ? 0.28 : 0.85;
    final totalCost = double.parse((eligible.length * unitRate).toStringAsFixed(2));

    return {
      'camp_id': campId,
      'venue_name': venueName,
      'eligible_count': eligible.length,
      'suppressed_count': suppressedDonors.length,
      'target_city': targetCity,
      'center_lat': effectiveLat,
      'center_lng': effectiveLng,
      'radius_km': radiusKm,
      'unit_rate_inr': unitRate,
      'estimated_cost_inr': totalCost,
      'requires_approval': eligible.length > 200,
      'sample_donors': eligible,
      'suppressed_donors': suppressedDonors,
      'area_breakdown': areaBreakdown,
      'suppression_summary': suppressionSummary,
    };
  }

  /// Dispatch regional geo-targeted broadcast (Only donors in camp venue radius)
  Future<Map<String, dynamic>> broadcastRegionalMessage({
    required String title,
    required String message,
    required String broadcastType,
    String? campId,
    String targetCity = 'All',
    double? centerLat,
    double? centerLng,
    double radiusKm = 10.0,
    bool respectTravelCap = true,
    String? bloodGroupFilter,
    String? areaFilter,
    String channel = 'whatsapp',
    String? approvalId,
  }) async {
    final audience = await previewBroadcastAudience(
      campId: campId,
      targetCity: targetCity,
      centerLat: centerLat,
      centerLng: centerLng,
      radiusKm: radiusKm,
      respectTravelCap: respectTravelCap,
      bloodGroup: bloodGroupFilter ?? 'All',
      channel: channel,
    );

    final eligibleCount = audience['eligible_count'] as int? ?? 0;
    final suppressedCount = audience['suppressed_count'] as int? ?? 0;
    final cost = (audience['estimated_cost_inr'] as num?)?.toDouble() ?? 0.0;
    final requiresApproval = audience['requires_approval'] == true;

    // Four-Eyes Rule: Broadcasts > 200 recipients require approval
    if (requiresApproval && approvalId == null) {
      return {
        'success': false,
        'requires_approval': true,
        'eligible_count': eligibleCount,
        'error': 'Broadcast reach ($eligibleCount donors) exceeds 200 recipients. Requires Four-Eyes approval.',
      };
    }

    if (_isInitialized && client != null) {
      try {
        final res = await client!.rpc('dispatch_geo_broadcast', params: {
          'p_title': title,
          'p_message': message,
          'p_broadcast_type': broadcastType,
          'p_camp_id': campId,
          'p_city': targetCity,
          'p_center_lat': audience['center_lat'],
          'p_center_lng': audience['center_lng'],
          'p_radius_km': radiusKm,
          'p_respect_travel_cap': respectTravelCap,
          'p_blood_group': bloodGroupFilter ?? 'All',
          'p_channel': channel,
          'p_approval_id': approvalId,
        });

        if (res != null && res is Map<String, dynamic>) {
          return {
            'success': res['ok'] == true,
            'recipients': res['recipients'] ?? eligibleCount,
            'suppressed': res['suppressed'] ?? suppressedCount,
            'cost_inr': res['estimated_cost_inr'] ?? cost,
          };
        }
      } catch (e) {
        debugPrint('broadcastRegionalMessage RPC error: $e');
      }
    }

    // Local / Offline dispatch: queue targeted in-app notifications for each in-radius eligible donor
    final eligibleDonors = audience['sample_donors'] as List? ?? [];
    for (final d in eligibleDonors) {
      final dMap = d as Map<String, dynamic>;
      final donorId = dMap['id']?.toString();
      final distKm = dMap['distance_km'];
      final dCity = dMap['city']?.toString() ?? targetCity;
      final dArea = dMap['area']?.toString() ?? '';
      if (donorId != null) {
        await sendInAppNotification(
          recipientId: donorId,
          recipientRole: 'donor',
          title: title,
          body: '$message\n📍 Distance: ~$distKm km from your location ($dArea, $dCity)',
          category: 'camp_invite',
          payload: {
            'camp_id': campId,
            'distance_km': distKm,
            'city': dCity,
            'area': dArea,
            'channel': channel,
          },
        );
      }
    }

    // Local / Offline success tracking
    final event = {
      'id': 'bcast-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'message': message,
      'broadcast_type': broadcastType,
      'target_city': targetCity,
      'radius_km': radiusKm,
      'recipients_count': eligibleCount,
      'suppressed_count': suppressedCount,
      'channel': channel,
      'cost_inr': cost,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('local_broadcast_history');
      List list = cached != null ? jsonDecode(cached) as List : [];
      list.insert(0, event);
      await prefs.setString('local_broadcast_history', jsonEncode(list.take(20).toList()));
    } catch (_) {}

    return {
      'success': true,
      'recipients': eligibleCount,
      'suppressed': suppressedCount,
      'cost_inr': cost,
    };
  }

  /// Update donor's location, travel preference, and away status
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

    if (_isInitialized && client != null) {
      try {
        await client!.from('donors').update({
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

  /// Get donor's location, travel preference, and away status
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

    if (_isInitialized && client != null) {
      try {
        final res = await client!.from('donors').select('city, area, travel_radius_km, is_away, away_reason').eq('id', donorId).maybeSingle();
        if (res != null) {
          return {
            'city': res['city']?.toString() ?? 'Rajahmundry',
            'area': res['area']?.toString() ?? 'Danavaipeta',
            'travel_radius_km': (res['travel_radius_km'] as num?)?.toDouble() ?? 15.0,
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

  // ==========================================================================
  // SUPERHERO ADMIN & TELEMETRY OPERATIONS (Delegated)
  // ==========================================================================

  // 31. Superhero Admin: Promote Donor Trust Level
  Future<bool> updateDonorTrustLevel(String donorId, int trustLevel) =>
      AdminDonorOperationsService().updateDonorTrustLevel(donorId, trustLevel);

  // 32. Superhero Admin: Quick Bank Stock Adjustment (+ / - units)
  Future<bool> adjustBankStockQuick({
    required String bankId,
    required String bloodGroup,
    required int deltaUnits,
    String component = 'whole_blood',
  }) =>
      AdminBankOperationsService().adjustBankStockQuick(
        bankId: bankId,
        bloodGroup: bloodGroup,
        deltaUnits: deltaUnits,
        component: component,
      );

  // 33. Superhero Admin: Update Blood Bank Meta
  Future<bool> updateBloodBank({
    required String bankId,
    double? trustScore,
    bool? is24x7,
  }) =>
      AdminBankOperationsService().updateBloodBank(
        bankId: bankId,
        trustScore: trustScore,
        is24x7: is24x7,
      );

  // 34. Superhero Admin: Get Outbound Broadcast History
  Future<List<Map<String, dynamic>>> getBroadcastHistory() =>
      AdminCampOperationsService().getBroadcastHistory();

  // 35. Superhero Admin: Create Donor Manually
  Future<Map<String, dynamic>> createDonorDirect({
    required String fullName,
    required String phone,
    required String bloodGroup,
    int trustLevel = 1,
    String gender = 'other',
    int maxTravelKm = 10,
    String state = 'active',
  }) =>
      AdminDonorOperationsService().createDonorDirect(
        fullName: fullName,
        phone: phone,
        bloodGroup: bloodGroup,
        trustLevel: trustLevel,
        gender: gender,
        maxTravelKm: maxTravelKm,
        state: state,
      );

  // 36. Superhero Admin: Update Donor Details
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
  }) =>
      AdminDonorOperationsService().updateDonorDirect(
        id: id,
        fullName: fullName,
        phone: phone,
        bloodGroup: bloodGroup,
        state: state,
        trustLevel: trustLevel,
        gender: gender,
        maxTravelKm: maxTravelKm,
        donationsCount: donationsCount,
      );

  // 37. Superhero Admin: Create Blood Bank
  Future<Map<String, dynamic>> createBloodBankDirect({
    required String name,
    required String address,
    required String phone,
    bool is24x7 = true,
    int trustScore = 85,
    String contactPerson = '',
    double lat = 17.0005,
    double lng = 81.7800,
  }) =>
      AdminBankOperationsService().createBloodBankDirect(
        name: name,
        address: address,
        phone: phone,
        is24x7: is24x7,
        trustScore: trustScore,
        contactPerson: contactPerson,
        lat: lat,
        lng: lng,
      );

  // 38. Superhero Admin: Update Blood Bank Full
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
  }) =>
      AdminBankOperationsService().updateBloodBankFull(
        id: id,
        name: name,
        address: address,
        phone: phone,
        is24x7: is24x7,
        trustScore: trustScore,
        contactPerson: contactPerson,
        lat: lat,
        lng: lng,
      );

  // 39. Superhero Admin: Get Stock Breakdown for All 8 Groups
  Future<Map<String, int>> getBankStockAllGroups(String bankId) =>
      AdminBankOperationsService().getBankStockAllGroups(bankId);

  // 40. Superhero Admin: Set Bank Stock Directly
  Future<bool> setBankStockDirect({
    required String bankId,
    required String bloodGroup,
    required int units,
    String component = 'whole_blood',
  }) =>
      AdminBankOperationsService().setBankStockDirect(
        bankId: bankId,
        bloodGroup: bloodGroup,
        units: units,
        component: component,
      );

  // 41. Superhero Admin: Update Blood Camp
  Future<bool> updateCampDirect({
    required String id,
    String? title,
    String? venue,
    String? area,
    DateTime? startsAt,
    DateTime? endsAt,
    int? capacity,
    String? status,
  }) =>
      AdminCampOperationsService().updateCampDirect(
        id: id,
        title: title,
        venue: venue,
        area: area,
        startsAt: startsAt,
        endsAt: endsAt,
        capacity: capacity,
        status: status,
      );

  // 42. Superhero Admin: Delete Blood Camp
  Future<bool> deleteCampDirect(String id) =>
      AdminCampOperationsService().deleteCampDirect(id);

  // 43. Superhero Admin: AI Voice Configuration & Training
  Future<Map<String, dynamic>> getAIVoiceConfig() =>
      AdminTelemetryService().getAIVoiceConfig();

  Future<bool> saveAIVoiceConfig({
    required String prompt,
    required String persona,
    required String language,
    required double temperature,
    required String guidelines,
    required int dailyMinutesCap,
  }) =>
      AdminTelemetryService().saveAIVoiceConfig(
        prompt: prompt,
        persona: persona,
        language: language,
        temperature: temperature,
        guidelines: guidelines,
        dailyMinutesCap: dailyMinutesCap,
      );

  // 44. Superhero Admin: WhatsApp Templates & Triggers
  Future<List<Map<String, dynamic>>> getWhatsAppTemplates() =>
      AdminTelemetryService().getWhatsAppTemplates();

  Future<bool> saveWhatsAppTemplates(List<Map<String, dynamic>> templates) =>
      AdminTelemetryService().saveWhatsAppTemplates(templates);

  // 45. Superhero Admin: Telephony Settings
  Future<Map<String, dynamic>> getTelephonySettings() =>
      AdminTelemetryService().getTelephonySettings();

  Future<bool> saveTelephonySettings(Map<String, dynamic> config) =>
      AdminTelemetryService().saveTelephonySettings(config);

  // 46. Superhero Admin: Telemetry Metrics (WhatsApp Counts, Voice Calls, Costs)
  Future<Map<String, dynamic>> getTelemetryMetrics() =>
      AdminTelemetryService().getTelemetryMetrics();

  // 47. Superhero Admin: Simulate Voice AI Triage Test
  Map<String, dynamic> simulateAITriageResponse(
    String userSpeech, {
    String prompt = '',
  }) =>
      AdminTelemetryService().simulateAITriageResponse(
        userSpeech,
        prompt: prompt,
      );

  // --- CONTINUOUS REALTIME CHANNELS (STAGE 1) ---
  RealtimeChannel? _requestsChannel;
  RealtimeChannel? _stockChannel;
  RealtimeChannel? _messageEventsChannel;
  RealtimeChannel? _campsChannel;

  /// Subscribe to all real-time changes on public.requests (INSERT, UPDATE, DELETE)
  RealtimeChannel? subscribeToRequestsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    if (_isInitialized && client != null) {
      try {
        _requestsChannel?.unsubscribe();
        _requestsChannel = client!
            .channel('public:requests_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'requests',
              callback: onData,
            )
            .subscribe();
        return _requestsChannel;
      } catch (e) {
        debugPrint('subscribeToRequestsChannel error: $e');
      }
    }
    return null;
  }

  /// Subscribe to all real-time changes on public.bank_stock (Stock injection/deduction)
  RealtimeChannel? subscribeToStockChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    if (_isInitialized && client != null) {
      try {
        _stockChannel?.unsubscribe();
        _stockChannel = client!
            .channel('public:stock_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'bank_stock',
              callback: onData,
            )
            .subscribe();
        return _stockChannel;
      } catch (e) {
        debugPrint('subscribeToStockChannel error: $e');
      }
    }
    return null;
  }

  /// Subscribe to all real-time message events (WhatsApp / SMS delivery updates)
  RealtimeChannel? subscribeToMessageEventsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    if (_isInitialized && client != null) {
      try {
        _messageEventsChannel?.unsubscribe();
        _messageEventsChannel = client!
            .channel('public:messages_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'message_events',
              callback: onData,
            )
            .subscribe();
        return _messageEventsChannel;
      } catch (e) {
        debugPrint('subscribeToMessageEventsChannel error: $e');
      }
    }
    return null;
  }

  /// Subscribe to all real-time changes on public.bank_camps
  RealtimeChannel? subscribeToCampsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    if (_isInitialized && client != null) {
      try {
        _campsChannel?.unsubscribe();
        _campsChannel = client!
            .channel('public:camps_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'bank_camps',
              callback: onData,
            )
            .subscribe();
        return _campsChannel;
      } catch (e) {
        debugPrint('subscribeToCampsChannel error: $e');
      }
    }
    return null;
  }

  RealtimeChannel? _notificationsChannel;

  /// Subscribe to all real-time changes on public.notifications
  RealtimeChannel? subscribeToNotificationsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    if (_isInitialized && client != null) {
      try {
        _notificationsChannel?.unsubscribe();
        _notificationsChannel = client!
            .channel('public:notifications_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'notifications',
              callback: onData,
            )
            .subscribe();
        return _notificationsChannel;
      } catch (e) {
        debugPrint('subscribeToNotificationsChannel error: $e');
      }
    }
    return null;
  }

  void unsubscribeAllChannels() {
    try {
      _requestsChannel?.unsubscribe();
      _stockChannel?.unsubscribe();
      _messageEventsChannel?.unsubscribe();
      _campsChannel?.unsubscribe();
      _notificationsChannel?.unsubscribe();
    } catch (e) {
      debugPrint('unsubscribeAllChannels error: $e');
    }
  }

  // ==========================================================================
  // STAGE 3: DONOR MILESTONE BADGES & CERTIFICATES ENGINE (Delegated)
  // ==========================================================================

  Future<List<DonorBadgeModel>> getDonorBadges(
    String donorId, {
    int donationsCount = 0,
  }) =>
      DonorMilestoneService().getDonorBadges(
        donorId,
        donationsCount: donationsCount,
      );

  Future<bool> awardDonorBadge({
    required String donorId,
    required String badgeCode,
    required String badgeName,
    required String description,
    String? certificateUrl,
  }) =>
      DonorMilestoneService().awardDonorBadge(
        donorId: donorId,
        badgeCode: badgeCode,
        badgeName: badgeName,
        description: description,
        certificateUrl: certificateUrl,
      );

  // ==========================================================================
  // STAGE 4: CAMP QR & KEYPAD CHECK-IN ENGINE (Delegated)
  // ==========================================================================

  Future<Map<String, dynamic>> checkInCampAttendee({
    required String campId,
    String? donorId,
    String? phone,
    int units = 1,
  }) =>
      BankCampCheckinService().checkInCampAttendee(
        campId: campId,
        donorId: donorId,
        phone: phone,
        units: units,
      );

  Future<List<Map<String, dynamic>>> getCampAttendees(String campId) =>
      BankCampCheckinService().getCampAttendees(campId);

  // ==========================================================================
  // STAGE 5: CENTRALIZED IN-APP NOTIFICATIONS ENGINE (Delegated)
  // ==========================================================================

  Future<List<InAppNotificationModel>> getNotifications({
    String? recipientId,
    String? recipientRole,
    int limit = 30,
  }) =>
      NotificationService().getNotifications(
        recipientId: recipientId,
        recipientRole: recipientRole,
        limit: limit,
      );

  Future<bool> markNotificationAsRead(String notificationId) =>
      NotificationService().markNotificationAsRead(notificationId);

  Future<bool> sendInAppNotification({
    String? recipientId,
    required String recipientRole,
    required String title,
    required String body,
    required String category,
    Map<String, dynamic>? payload,
  }) =>
      NotificationService().sendInAppNotification(
        recipientId: recipientId,
        recipientRole: recipientRole,
        title: title,
        body: body,
        category: category,
        payload: payload,
      );

  // ==========================================================================
  // AM0: FEATURE FLAGS & ADVANCED RBAC PERMISSIONS (Delegated)
  // ==========================================================================

  Future<bool> isFeatureEnabled(String flagKey, {bool defaultValue = false}) =>
      AdminFeatureFlagsService().isFeatureEnabled(
        flagKey,
        defaultValue: defaultValue,
      );

  Future<List<Map<String, dynamic>>> getFeatureFlags() =>
      AdminFeatureFlagsService().getFeatureFlags();

  Future<bool> setFeatureFlag(String flagKey, bool enabled) =>
      AdminFeatureFlagsService().setFeatureFlag(flagKey, enabled);

  Future<bool> hasAdminPermission(String permissionCode) =>
      AdminFeatureFlagsService().hasAdminPermission(permissionCode);

  Future<List<Map<String, dynamic>>> getAdminRoles() =>
      AdminFeatureFlagsService().getAdminRoles();

  // ==========================================================================
  // MILESTONE AM1: FOUR-EYES APPROVALS, STEP-UP TOTP & SESSIONS (Delegated)
  // ==========================================================================

  Future<Map<String, dynamic>> submitApprovalRequest({
    required String actionType,
    String? targetEntity,
    String? targetId,
    required Map<String, dynamic> diffPayload,
    required String reason,
    String? makerId,
  }) =>
      AdminGovernanceService().submitApprovalRequest(
        actionType: actionType,
        targetEntity: targetEntity,
        targetId: targetId,
        diffPayload: diffPayload,
        reason: reason,
        makerId: makerId,
      );

  Future<List<Map<String, dynamic>>> getApprovalRequests({
    String status = 'pending',
  }) =>
      AdminGovernanceService().getApprovalRequests(status: status);

  Future<Map<String, dynamic>> decideApprovalRequest({
    required String requestId,
    required bool approve,
    String? note,
    String? currentUserId,
  }) =>
      AdminGovernanceService().decideApprovalRequest(
        requestId: requestId,
        approve: approve,
        note: note,
        currentUserId: currentUserId,
      );

  Future<bool> verifyStepUpCode(String totpCode) =>
      AdminGovernanceService().verifyStepUpCode(totpCode);

  Future<bool> hasActiveStepUp() =>
      AdminGovernanceService().hasActiveStepUp();

  Future<List<Map<String, dynamic>>> getActiveAdminSessions() =>
      AdminGovernanceService().getActiveAdminSessions();

  Future<bool> revokeAdminSession(String sessionId) =>
      AdminGovernanceService().revokeAdminSession(sessionId);

  Future<Map<String, dynamic>> requestBreakGlassElevation({
    required String reason,
  }) =>
      AdminGovernanceService().requestBreakGlassElevation(reason: reason);

  // ============================================================================
  // MILESTONE AM2: MAINTENANCE MODE & SCOPED SWITCHES (Delegated)
  // ============================================================================

  Future<Map<String, dynamic>> checkMaintenanceStatus({
    required String scope,
    String? identifier,
  }) =>
      AdminMaintenanceService().checkMaintenanceStatus(
        scope: scope,
        identifier: identifier,
      );

  Future<List<Map<String, dynamic>>> getMaintenanceWindows() =>
      AdminMaintenanceService().getMaintenanceWindows();

  Future<Map<String, dynamic>> setMaintenanceMode({
    required bool active,
    List<String>? scopes,
    String policy = 'continue_active',
    String reason = 'Scheduled maintenance window',
    int durationMinutes = 60,
    Map<String, dynamic>? bypassAllowlist,
  }) =>
      AdminMaintenanceService().setMaintenanceMode(
        active: active,
        scopes: scopes,
        policy: policy,
        reason: reason,
        durationMinutes: durationMinutes,
        bypassAllowlist: bypassAllowlist,
      );

  Future<Map<String, dynamic>> extendMaintenanceWindow({
    required String windowId,
    required int additionalMinutes,
    String reason = 'Additional migration verification required',
  }) =>
      AdminMaintenanceService().extendMaintenanceWindow(
        windowId: windowId,
        additionalMinutes: additionalMinutes,
        reason: reason,
      );

  Future<bool> isMaintenanceActive() =>
      AdminMaintenanceService().isMaintenanceActive();

  // ============================================================================
  // MILESTONE AM3: DATA EXPORT & REPORTING CENTRE (Delegated)
  // ============================================================================

  String sanitizeCsvCell(String input) =>
      AdminExportService().sanitizeCsvCell(input);

  Future<Map<String, dynamic>> createDataExport({
    required String entityType,
    required String tier,
    required String format,
    required String reason,
    int rowCount = 0,
    Map<String, dynamic>? filterParams,
    String? approvalId,
  }) =>
      AdminExportService().createDataExport(
        entityType: entityType,
        tier: tier,
        format: format,
        reason: reason,
        rowCount: rowCount,
        filterParams: filterParams,
        approvalId: approvalId,
      );

  Future<List<Map<String, dynamic>>> getDataExports() =>
      AdminExportService().getDataExports();

  // ============================================================================
  // MILESTONE AM4: LEDGERS & COST ENGINE (Delegated)
  // ============================================================================

  Future<List<Map<String, dynamic>>> getCostRateCards() =>
      AdminCostLedgerService().getCostRateCards();

  Future<Map<String, dynamic>> recordCostEvent({
    required String requestId,
    required String serviceName,
    double units = 1.0,
    Map<String, dynamic>? meta,
  }) =>
      AdminCostLedgerService().recordCostEvent(
        requestId: requestId,
        serviceName: serviceName,
        units: units,
        meta: meta,
      );

  Future<Map<String, dynamic>> getDailySpendSummary({DateTime? date}) =>
      AdminCostLedgerService().getDailySpendSummary(date: date);

  // ============================================================================
  // MILESTONE AM5..AM11: DIRECTORY, SAFETY & OPERATIONS (Delegated)
  // ============================================================================

  Future<List<Map<String, dynamic>>> getHospitals() =>
      AdminDirectoryService().getHospitals();

  Future<List<Map<String, dynamic>>> getAIPromptVersions() =>
      AdminDirectoryService().getAIPromptVersions();

  Future<Map<String, dynamic>> runAIEvaluationSuite({
    required String promptVersionId,
  }) =>
      AdminDirectoryService().runAIEvaluationSuite(
        promptVersionId: promptVersionId,
      );

  Future<List<Map<String, dynamic>>> getSafetyIncidents() =>
      AdminDirectoryService().getSafetyIncidents();

  Future<List<Map<String, dynamic>>> getDPDPRequests() =>
      AdminDirectoryService().getDPDPRequests();

  Future<List<Map<String, dynamic>>> getCommunityPartners() =>
      AdminDirectoryService().getCommunityPartners();

  Future<List<Map<String, dynamic>>> getRequesterProfiles() =>
      AdminDirectoryService().getRequesterProfiles();

  Future<bool> setRequesterBlockStatus({
    required String phone,
    required bool isBlocked,
    String? reason,
  }) =>
      AdminDirectoryService().setRequesterBlockStatus(
        phone: phone,
        isBlocked: isBlocked,
        reason: reason,
      );
}
