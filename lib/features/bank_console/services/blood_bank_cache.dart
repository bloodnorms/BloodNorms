// ============================================================================
// BloodNorms | blood_bank_cache.dart
// Offline local cache persistence for blood banks
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/blood_bank_model.dart';

class BloodBankCache {
  static const String _cachedBanksKey = 'cached_blood_banks_list';

  static Future<void> cache(List<BloodBankModel> banks) async {
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

  static Future<List<BloodBankModel>> get() async {
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
}
