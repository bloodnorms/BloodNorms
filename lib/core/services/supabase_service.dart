// ============================================================================
// BloodNorms | supabase_service.dart
// Supabase client integration, authentication, PostGIS RPCs, Realtime channels
// Includes graceful fallback mode for offline/testing
// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class BloodBankModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String? district;
  final List<String> phones;
  final bool is24x7;
  final double distanceKm;
  final int stockUnits;
  final String stockFreshness;
  final int trustScore;
  final String trustLabel;
  final DateTime? stockUpdatedAt;
  final double? latitude;
  final double? longitude;

  double get lat => latitude ?? (16.9890 + (id.hashCode % 10) * 0.003);
  double get lng => longitude ?? (81.7840 + (id.hashCode % 10) * 0.003);
  double get distanceMeters => distanceKm * 1000;
  int get unitsAvailable => stockUnits;
  bool get isOpen24x7 => is24x7;
  String get phone => phones.isNotEmpty ? phones.first : '+91 883 2471234';

  BloodBankModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.district,
    required this.phones,
    required this.is24x7,
    required this.distanceKm,
    required this.stockUnits,
    required this.stockFreshness,
    required this.trustScore,
    required this.trustLabel,
    this.stockUpdatedAt,
    this.latitude,
    this.longitude,
  });

  factory BloodBankModel.fromJson(Map<String, dynamic> json) {
    return BloodBankModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Blood Bank',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? AppConstants.pilotCity,
      district: json['district']?.toString(),
      phones: (json['phones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      is24x7: json['is_24x7'] == true,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.5,
      stockUnits: (json['stock_units'] as num?)?.toInt() ?? 0,
      stockFreshness: json['stock_freshness']?.toString() ?? 'fresh',
      trustScore: (json['trust_score'] as num?)?.toInt() ?? 50,
      trustLabel: json['trust_label']?.toString() ?? 'OK',
      stockUpdatedAt: json['stock_updated_at'] != null
          ? DateTime.tryParse(json['stock_updated_at'].toString())
          : null,
      latitude: (json['lat'] ?? json['latitude']) != null
          ? ((json['lat'] ?? json['latitude']) as num).toDouble()
          : null,
      longitude: (json['lng'] ?? json['longitude']) != null
          ? ((json['lng'] ?? json['longitude']) as num).toDouble()
          : null,
    );
  }
}

class DonorCardModel {
  final String id;
  final String firstName;
  final String bloodGroup;
  final String distanceBand;
  final int etaMinutes;
  final String status;
  final bool isStandby;
  final bool phoneRevealed;
  final String? phone;

  DonorCardModel({
    required this.id,
    required this.firstName,
    required this.bloodGroup,
    required this.distanceBand,
    required this.etaMinutes,
    required this.status,
    required this.isStandby,
    required this.phoneRevealed,
    this.phone,
  });

  factory DonorCardModel.fromJson(Map<String, dynamic> json) {
    return DonorCardModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? 'Donor',
      bloodGroup: json['blood_group']?.toString() ?? 'O+',
      distanceBand: json['distance_band']?.toString() ?? '< 3 km',
      etaMinutes: (json['eta_minutes'] as num?)?.toInt() ?? 25,
      status: json['status']?.toString() ?? 'accepted',
      isStandby: json['is_standby'] == true,
      phoneRevealed: json['phone_revealed'] == true,
      phone: json['phone']?.toString(),
    );
  }
}

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  Future<void> initialize({String? url, String? anonKey}) async {
    final effectiveUrl = url ?? AppConstants.defaultSupabaseUrl;
    final effectiveKey = anonKey ?? AppConstants.defaultSupabaseAnonKey;

    try {
      await Supabase.initialize(
        url: effectiveUrl,
        // ignore: deprecated_member_use
        anonKey: effectiveKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Supabase init notice: running in local mock fallback mode ($e)');
      _isInitialized = false;
    }
  }

  SupabaseClient? get client => _isInitialized ? Supabase.instance.client : null;

  User? get currentUser => client?.auth.currentUser;

  // 1. Nearest Banks via SQL Function RPC
  Future<List<BloodBankModel>> getNearestBanks({
    required double lat,
    required double lng,
    String? bloodGroup,
    String component = 'whole_blood',
  }) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!.rpc('nearest_banks', params: {
          'p_lat': lat,
          'p_lng': lng,
          'p_group': bloodGroup,
          'p_component': component,
          'p_limit': 10,
          'p_max_km': 100.0,
        });

        if (res is List) {
          return res.map((item) => BloodBankModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      } catch (e) {
        debugPrint('getNearestBanks RPC error: $e');
      }
    }

    // High fidelity pilot data fallback (Rajahmundry)
    return [
      BloodBankModel(
        id: '1',
        name: 'Rotary Central Blood Bank',
        address: 'Near Danavaipeta Park, Main Road',
        city: 'Rajahmundry',
        district: 'East Godavari',
        phones: ['+918832471234', '+919848123456'],
        is24x7: true,
        distanceKm: 1.2,
        stockUnits: 6,
        stockFreshness: 'fresh',
        trustScore: 85,
        trustLabel: 'Reliable',
        stockUpdatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      BloodBankModel(
        id: '2',
        name: 'Government General Hospital Blood Bank',
        address: 'Opposite Collectorate, Hospital Road',
        city: 'Rajahmundry',
        district: 'East Godavari',
        phones: ['+918832467890'],
        is24x7: true,
        distanceKm: 2.8,
        stockUnits: 3,
        stockFreshness: 'moderate',
        trustScore: 75,
        trustLabel: 'OK',
        stockUpdatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      BloodBankModel(
        id: '3',
        name: 'Indian Red Cross Society Blood Centre',
        address: 'Red Cross Bhavan, Gandhipuram',
        city: 'Rajahmundry',
        district: 'East Godavari',
        phones: ['+918832445566'],
        is24x7: false,
        distanceKm: 3.5,
        stockUnits: 2,
        stockFreshness: 'fresh',
        trustScore: 90,
        trustLabel: 'Reliable',
        stockUpdatedAt: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
    ];
  }

  // 2. Create Request
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
    if (_isInitialized && client != null && currentUser != null) {
      final res = await client!.rpc('create_request_for_user', params: {
        'p_user_id': currentUser!.id,
        'p_origin': 'web',
        'p_origin_session_id': null,
        'p_blood_group': bloodGroup,
        'p_component': component,
        'p_units': unitsNeeded,
        'p_urgency': urgency,
        'p_hospital_name': hospitalName,
        'p_hospital_area': hospitalArea,
        'p_lat': lat,
        'p_lng': lng,
        'p_requester_name': requesterName,
        'p_requester_phone': requesterPhone,
        'p_requester_relation': 'family',
        'p_patient_first_name': patientFirstName,
        'p_patient_age': patientAge,
        'p_allow_compatible': allowCompatible,
        'p_note': note,
      });
      return res.toString();
    }

    // Local simulated request ID
    return 'req-${DateTime.now().millisecondsSinceEpoch}';
  }

  // 3. Confirm Donation at Blood Bank
  Future<Map<String, dynamic>> confirmBankDonation({
    required String code,
    String? donorLast4,
  }) async {
    if (_isInitialized && client != null) {
      final res = await client!.rpc('bank_confirm_donation', params: {
        'p_code': code,
        'p_donor_last4': donorLast4,
      });
      return Map<String, dynamic>.from(res);
    }

    // Local simulated confirmation
    return {
      'ok': true,
      'first_name': 'Ramesh',
      'blood_group': 'O+',
      'request_id': 'req-sim-001',
    };
  }

  // 4. Update Bank Stock
  Future<int> setBankStock(List<Map<String, dynamic>> rows) async {
    if (_isInitialized && client != null) {
      final res = await client!.rpc('bank_set_stock', params: {
        'p_rows': rows,
      });
      return (res as num).toInt();
    }
    return rows.length;
  }
}

