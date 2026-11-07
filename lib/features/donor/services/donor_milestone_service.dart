// ============================================================================
// BloodNorms | donor_milestone_service.dart
// Donor milestone badges, honor ladder calculation, and certificate awards
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/donor_badge_model.dart';
import '../../../shared/services/supabase_service.dart';

class DonorMilestoneService {
  static final DonorMilestoneService _instance = DonorMilestoneService._internal();
  factory DonorMilestoneService() => _instance;
  DonorMilestoneService._internal();

  /// Fetch all milestone badges for a donor (both unlocked and locked with progress)
  Future<List<DonorBadgeModel>> getDonorBadges(
    String donorId, {
    int donationsCount = 0,
  }) async {
    final Map<String, dynamic> unlockedBadgesMap = {};
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    // 1. Load unlocked badges from local cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('donor_badges_$donorId');
      if (cachedJson != null) {
        final List decoded = jsonDecode(cachedJson) as List;
        for (final item in decoded) {
          if (item is Map) {
            unlockedBadgesMap[item['badge_code']?.toString() ?? ''] = item;
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading local donor badges: $e');
    }

    // 2. Fetch live unlocked badges from Supabase
    if (isInitialized && client != null && donorId.isNotEmpty) {
      try {
        final response = await client
            .from('donor_badges')
            .select()
            .eq('donor_id', donorId);
        final list = response as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            unlockedBadgesMap[item['badge_code']?.toString() ?? ''] = item;
          }
        }
      } catch (e) {
        debugPrint('Supabase getDonorBadges table error: $e');
      }
    }

    // 3. Define standard milestone badge ladder
    final ladder = [
      {
        'code': 'bronze_hero',
        'name': 'Bronze Hero',
        'desc': 'First verified blood donation recorded',
        'req': 1,
        'icon': '🥉',
      },
      {
        'code': 'silver_guardian',
        'name': 'Silver Guardian',
        'desc': '3 lives saved through emergency response',
        'req': 3,
        'icon': '🥈',
      },
      {
        'code': 'gold_lifesaver',
        'name': 'Gold Lifesaver',
        'desc': '5 donations - community lifeline pillar',
        'req': 5,
        'icon': '🥇',
      },
      {
        'code': 'platinum_savior',
        'name': 'Platinum Savior',
        'desc': '10 verified donations across Andhra Pradesh',
        'req': 10,
        'icon': '💎',
      },
      {
        'code': 'centurion',
        'name': 'Centurion Lifesaver',
        'desc': '25+ life donations - Hall of Fame',
        'req': 25,
        'icon': '👑',
      },
    ];

    final List<DonorBadgeModel> badges = [];
    for (final item in ladder) {
      final code = item['code'] as String;
      final req = item['req'] as int;
      final bool isEarned =
          (donationsCount >= req) || unlockedBadgesMap.containsKey(code);

      DateTime unlockedAt = DateTime.now();
      String? certUrl;

      if (unlockedBadgesMap.containsKey(code)) {
        final raw = unlockedBadgesMap[code];
        unlockedAt =
            DateTime.tryParse(raw['unlocked_at']?.toString() ?? '') ??
                DateTime.now();
        certUrl = raw['certificate_url']?.toString();
      }

      badges.add(DonorBadgeModel(
        id: unlockedBadgesMap[code]?['id']?.toString() ?? 'badge-$code',
        donorId: donorId,
        badgeCode: code,
        badgeName: item['name'] as String,
        description: item['desc'] as String,
        unlockedAt: unlockedAt,
        certificateUrl: certUrl,
        isUnlocked: isEarned,
        requiredDonations: req,
        icon: item['icon'] as String,
      ));
    }

    return badges;
  }

  /// Award a milestone badge to a donor in Supabase & cache locally
  Future<bool> awardDonorBadge({
    required String donorId,
    required String badgeCode,
    required String badgeName,
    required String description,
    String? certificateUrl,
  }) async {
    final newBadge = {
      'id': 'badge-${DateTime.now().millisecondsSinceEpoch}',
      'donor_id': donorId,
      'badge_code': badgeCode,
      'badge_name': badgeName,
      'description': description,
      'unlocked_at': DateTime.now().toIso8601String(),
      'certificate_url': certificateUrl,
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('donor_badges_$donorId');
      List list = [];
      if (cachedJson != null) {
        list = jsonDecode(cachedJson) as List;
      }
      list.removeWhere((item) => (item as Map)['badge_code'] == badgeCode);
      list.add(newBadge);
      await prefs.setString('donor_badges_$donorId', jsonEncode(list));
    } catch (e) {
      debugPrint('Error updating local badges cache: $e');
    }

    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    if (isInitialized && client != null && donorId.isNotEmpty) {
      try {
        await client
            .from('donor_badges')
            .upsert(newBadge, onConflict: 'donor_id,badge_code');
        return true;
      } catch (e) {
        debugPrint('Error saving badge to Supabase: $e');
      }
    }
    return true;
  }
}
