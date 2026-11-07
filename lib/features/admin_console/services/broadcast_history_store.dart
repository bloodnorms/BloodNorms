// ============================================================================
// BloodNorms | broadcast_history_store.dart
// SharedPreferences persistence for recent broadcast history events
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/notification_service.dart';

class BroadcastHistoryStore {
  static const String _key = 'local_broadcast_history';

  static Future<void> dispatchLocalNotifications({
    required List sampleDonors,
    required String title,
    required String message,
    required String targetCity,
    required String channel,
    String? campId,
  }) async {
    for (final d in sampleDonors) {
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
  }

  static Future<void> recordBroadcastEvent(Map<String, dynamic> event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_key);
      List list = cached != null ? jsonDecode(cached) as List : [];
      list.insert(0, event);
      await prefs.setString(_key, jsonEncode(list.take(20).toList()));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getBroadcastHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_key);
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }
}
