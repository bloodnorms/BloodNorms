// ============================================================================
// BloodNorms | blood_bank_service.dart
// Blood bank operations: stock queries, verification, nearby search, and caching
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/services/supabase_service.dart';

class BloodBankService {
  static final BloodBankService _instance = BloodBankService._internal();
  factory BloodBankService() => _instance;
  BloodBankService._internal();

  static const String _cachedBanksKey = 'cached_blood_banks_list';

  SupabaseClient? get _client => SupabaseService().client;

  /// Find nearest banks via RPC or table query with offline cache fallback
  Future<List<BloodBankModel>> getNearestBanks({
    required double lat,
    required double lng,
    String? bloodGroup,
    String component = 'whole_blood',
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client.rpc('find_nearby_banks_with_stock', params: {
          'p_lat': lat,
          'p_lng': lng,
          'p_blood_group': bloodGroup ?? 'O+',
          'p_radius_km': 50.0,
        });

        if (res is List && res.isNotEmpty) {
          final banks = res
              .map((item) =>
                  BloodBankModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cacheBloodBanks(banks);
          return banks;
        }
      } catch (e) {
        debugPrint('find_nearby_banks_with_stock RPC error: $e');
      }

      try {
        final res = await client.rpc('nearest_banks', params: {
          'p_lat': lat,
          'p_lng': lng,
          'p_group': bloodGroup,
          'p_component': component,
          'p_limit': 10,
          'p_max_km': 100.0,
        });

        if (res is List && res.isNotEmpty) {
          final banks = res
              .map((item) =>
                  BloodBankModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cacheBloodBanks(banks);
          return banks;
        }
      } catch (e) {
        debugPrint('nearest_banks RPC error: $e');
      }

      try {
        final res = await client.from('blood_banks').select().limit(10);
        if (res.isNotEmpty) {
          final banks = res
              .map((item) =>
                  BloodBankModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cacheBloodBanks(banks);
          return banks;
        }
      } catch (e) {
        debugPrint('direct blood_banks select error: $e');
      }
    }

    final cached = await getCachedBloodBanks();
    if (cached.isNotEmpty) {
      debugPrint('Returning ${cached.length} blood banks from cache');
      return cached;
    }

    return [];
  }

  /// Offline local cache persistence for blood banks
  Future<void> cacheBloodBanks(List<BloodBankModel> banks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = banks
          .map((b) => {
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
              })
          .toList();
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
        return decoded
            .map((item) =>
                BloodBankModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('getCachedBloodBanks error: $e');
    }
    return [];
  }

  /// Get blood bank stock by component
  Future<Map<String, int>> getBankStock({
    String? bankId,
    String component = 'whole_blood',
  }) async {
    final bId = bankId ?? 'b1000000-0000-0000-0000-000000000001';
    final map = <String, int>{
      'A+': 0, 'A-': 0, 'B+': 0, 'B-': 0,
      'AB+': 0, 'AB-': 0, 'O+': 0, 'O-': 0,
    };
    final client = _client;
    if (client != null) {
      try {
        final res = await client
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

  /// Update bank stock in batch
  Future<int> setBankStock(
    List<Map<String, dynamic>> rows, {
    String? bankId,
  }) async {
    final bId = bankId ?? 'b1000000-0000-0000-0000-000000000001';
    final client = _client;
    if (client != null) {
      try {
        final formattedRows = rows
            .map((r) => {
                  'bank_id': bId,
                  'blood_group': r['group'] ?? r['blood_group'],
                  'component': r['component'] ?? 'whole_blood',
                  'units': r['units'] ?? 0,
                  'source': 'bank_console',
                })
            .toList();

        final res = await client.rpc('bank_set_stock', params: {
          'p_rows': formattedRows,
        });
        return (res as num).toInt();
      } catch (e) {
        debugPrint('setBankStock RPC error: $e');
      }
    }
    return rows.length;
  }

  /// Confirm donation via 6-digit verification code
  Future<Map<String, dynamic>> confirmBankDonation({
    required String code,
    String? donorLast4,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final params = <String, dynamic>{'p_code': code};
        if (donorLast4 != null && donorLast4.isNotEmpty) {
          params['p_donor_last4'] = donorLast4;
        }
        final res = await client.rpc('bank_confirm_donation', params: params);
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

  /// Get list of all connected blood banks
  Future<List<Map<String, dynamic>>> getBanks() async {
    final client = _client;
    if (client != null) {
      try {
        final res =
            await client.from('blood_banks').select().order('name', ascending: true);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getBanks error: $e');
      }
    }
    return [];
  }
}
