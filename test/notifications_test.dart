// ============================================================================
// BloodNorms | notifications_test.dart
// Unit tests for Stage 5: In-App Notification Center
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Stage 5: Centralized In-App Notifications Engine', () {
    test('InAppNotificationModel parses and serializes correctly', () {
      final now = DateTime.now();
      final notification = InAppNotificationModel(
        id: 'notif-100',
        recipientId: 'user-001',
        recipientRole: 'donor',
        title: 'Emergency Alert: O- Required',
        body: 'Urgent donor needed at GGH Rajahmundry',
        category: 'emergency',
        payload: {'request_id': 'req-123', 'blood_group': 'O-'},
        isRead: false,
        createdAt: now,
      );

      final json = notification.toJson();
      final decoded = InAppNotificationModel.fromJson(json);

      expect(decoded.id, 'notif-100');
      expect(decoded.recipientId, 'user-001');
      expect(decoded.recipientRole, 'donor');
      expect(decoded.title, 'Emergency Alert: O- Required');
      expect(decoded.category, 'emergency');
      expect(decoded.isRead, isFalse);
      expect(decoded.payload['blood_group'], 'O-');
    });

    test('getNotifications provides baseline active announcements with zero empty state', () async {
      final service = SupabaseService();
      final notifications = await service.getNotifications(recipientRole: 'all');

      expect(notifications.isNotEmpty, isTrue);
      expect(notifications.any((n) => n.category == 'emergency'), isTrue);
      expect(notifications.any((n) => n.category == 'camp'), isTrue);
    });

    test('markNotificationAsRead updates status correctly', () async {
      final service = SupabaseService();
      final success = await service.markNotificationAsRead('notif-1');
      expect(success, isTrue);
    });

    test('sendInAppNotification queues entry and returns success', () async {
      final service = SupabaseService();
      final success = await service.sendInAppNotification(
        recipientRole: 'admin',
        title: 'Critical Stock Alert',
        body: 'B+ Whole Blood units below minimum threshold at GGH',
        category: 'stock',
        payload: {'bank_id': 'b-001', 'units': 2},
      );
      expect(success, isTrue);
    });
  });
}
