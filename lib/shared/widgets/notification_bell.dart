// ============================================================================
// BloodNorms | notification_bell.dart
// Realtime in-app notification bell with live unread badge and announcements sheet
// ============================================================================

import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';
import 'notifications_sheet.dart';

export 'notifications_sheet.dart';

class NotificationBell extends StatefulWidget {
  final String role; // 'admin', 'bank_staff', 'donor', 'requester', 'all'
  final String? recipientId;

  const NotificationBell({
    super.key,
    this.role = 'all',
    this.recipientId,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  List<InAppNotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await SupabaseService().getNotifications(
      recipientId: widget.recipientId,
      recipientRole: widget.role,
    );
    if (mounted) {
      setState(() => _notifications = list);
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _openSheet(BuildContext context) {
    showNotificationsSheet(
      context,
      notifications: _notifications,
      onRefresh: _loadNotifications,
      onMarkRead: (id) => SupabaseService().markNotificationAsRead(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _unreadCount;

    return InkWell(
      onTap: () => _openSheet(context),
      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: BrandColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          boxShadow: BrandColors.shadowSubtle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              size: 20,
              color: BrandColors.textPrimary,
            ),
            if (unread > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: BrandColors.statusError,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.0),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Backward compatibility alias for existing code.
typedef DuoNotificationBell = NotificationBell;
