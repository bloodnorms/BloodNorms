// ============================================================================
// BloodNorms | shared/models/notification_model.dart
//
// Data model for in-app notifications shown in the NotificationBell widget.
// Notifications target donors, bank staff, or all users by role.
// Deserialized from the `in_app_notifications` Supabase table.
// ============================================================================

/// An in-app notification delivered to a specific user or role group.
class InAppNotificationModel {
  final String id;

  /// UUID of the specific recipient, or null for broadcast notifications.
  final String? recipientId;

  /// Target role: 'donor', 'bank_staff', 'admin', or 'all'.
  final String recipientRole;

  final String title;
  final String body;

  /// Category for filtering/routing: 'request', 'camp', 'badge', 'system', etc.
  final String category;

  /// Arbitrary JSON payload (e.g., request ID, camp ID) for deep-linking.
  final Map<String, dynamic> payload;

  final bool isRead;
  final DateTime createdAt;

  const InAppNotificationModel({
    required this.id,
    this.recipientId,
    required this.recipientRole,
    required this.title,
    required this.body,
    required this.category,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory InAppNotificationModel.fromJson(Map<String, dynamic> json) {
    return InAppNotificationModel(
      id: json['id']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString(),
      recipientRole: json['recipient_role']?.toString() ?? 'all',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'system',
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'recipient_role': recipientRole,
      'title': title,
      'body': body,
      'category': category,
      'payload': payload,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

