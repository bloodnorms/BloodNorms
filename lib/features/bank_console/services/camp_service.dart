// ============================================================================
// BloodNorms | camp_service.dart
// Blood donation camp scheduling, queries, signups, and offline caching
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/constants/mock_camps.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/services/supabase_service.dart';

class CampService {
  static final CampService _instance = CampService._internal();
  factory CampService() => _instance;
  CampService._internal();

  static const String _cachedCampsKey = 'cached_blood_camps_list';

  SupabaseClient? get _client => SupabaseService().client;

  /// Cache camp listings locally
  Future<void> cacheCamps(List<CampModel> camps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = camps
          .map((c) => {
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
              })
          .toList();
      await prefs.setString(_cachedCampsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('cacheCamps error: $e');
    }
  }

  /// Retrieve cached camps
  Future<List<CampModel>> getCachedCamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedCampsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        return decoded
            .map((item) => CampModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('getCachedCamps error: $e');
    }
    return [];
  }

  /// Get blood donation camps from Supabase or baseline fallback
  Future<List<CampModel>> getCamps() async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('bank_camps')
            .select()
            .order('starts_at', ascending: true);
        if (res.isNotEmpty) {
          final camps = res
              .map((item) => CampModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cacheCamps(camps);
          return camps;
        }
      } catch (e) {
        debugPrint('getCamps error: $e');
      }
    }

    final cached = await getCachedCamps();
    if (cached.isNotEmpty) {
      debugPrint('Returning ${cached.length} camps from cache');
      return cached;
    }

    return getBaselineBloodCamps();
  }

  /// Sign up / RSVP donor for a camp
  Future<bool> joinCamp({required String campId, String? donorId}) async {
    final client = _client;
    if (client != null) {
      try {
        final dId = donorId ?? 'd1000000-0000-0000-0000-000000000001';
        await client.from('camp_signups').upsert({
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

  /// Create a new blood camp drive
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

    final client = _client;
    if (client != null) {
      try {
        await client.from('bank_camps').insert(campObj.toJson());
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

  /// Query set of camp IDs joined by donor
  Future<Set<String>> getDonorJoinedCampIds(String donorId) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
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
}
