// ============================================================================
// BloodNorms | admin_broadcast_service.dart
// Geo-targeted regional donor broadcasting with audience preview and budgeting
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/supabase_service.dart';
import '../../bank_console/services/camp_service.dart';
import 'broadcast_audience_filter.dart';

class AdminBroadcastService {
  static final AdminBroadcastService _instance =
      AdminBroadcastService._internal();
  factory AdminBroadcastService() => _instance;
  AdminBroadcastService._internal();

  SupabaseClient? get _client => SupabaseService().client;

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
    final client = _client;
    if (client != null) {
      try {
        final res = await client.rpc('preview_broadcast_audience', params: {
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

    double effectiveLat = centerLat ?? 17.0005;
    double effectiveLng = centerLng ?? 81.8040;
    String venueName = 'Designated Center';

    if (campId != null) {
      final camps = await CampService().getCamps();
      final camp = camps.where((c) => c.id == campId).firstOrNull;
      if (camp != null) {
        effectiveLat = camp.latitude ?? effectiveLat;
        effectiveLng = camp.longitude ?? effectiveLng;
        venueName = camp.venue;
      }
    }

    return computeLocalAudience(
      effectiveLat: effectiveLat,
      effectiveLng: effectiveLng,
      targetCity: targetCity,
      radiusKm: radiusKm,
      respectTravelCap: respectTravelCap,
      bloodGroup: bloodGroup,
      channel: channel,
      campId: campId,
      venueName: venueName,
    );
  }

  /// Dispatch regional geo-targeted broadcast
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

    if (requiresApproval && approvalId == null) {
      return {
        'success': false,
        'requires_approval': true,
        'eligible_count': eligibleCount,
        'error':
            'Broadcast reach ($eligibleCount donors) exceeds 200 recipients. Requires Four-Eyes approval.',
      };
    }

    final client = _client;
    if (client != null) {
      try {
        final res = await client.rpc('dispatch_geo_broadcast', params: {
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

    final eligibleDonors = audience['sample_donors'] as List? ?? [];
    for (final d in eligibleDonors) {
      final dMap = d as Map<String, dynamic>;
      final donorId = dMap['id']?.toString();
      final distKm = dMap['distance_km'];
      final dCity = dMap['city']?.toString() ?? targetCity;
      final dArea = dMap['area']?.toString() ?? '';
      if (donorId != null) {
        await NotificationService().sendInAppNotification(
          recipientId: donorId,
          recipientRole: 'donor',
          title: title,
          body:
              '$message\n📍 Distance: ~$distKm km from your location ($dArea, $dCity)',
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
      await prefs.setString(
          'local_broadcast_history', jsonEncode(list.take(20).toList()));
    } catch (_) {}

    return {
      'success': true,
      'recipients': eligibleCount,
      'suppressed': suppressedCount,
      'cost_inr': cost,
    };
  }
}
