// ============================================================================
// BloodNorms | donor_preferences_service.dart
// Donor location, radius preferences, and away status management
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';

class DonorPreferencesService {
  static final DonorPreferencesService _instance =
      DonorPreferencesService._internal();
  factory DonorPreferencesService() => _instance;
  DonorPreferencesService._internal();

  SupabaseClient? get _client => SupabaseService().client;

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
