// ============================================================================
// BloodNorms | duo_notification_bell.dart
// Realtime in-app notification bell with live badge and announcements sheet
// Duolingo Feather Red Style, Arial font, 3D tactile styling
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/duo_colors.dart';
import '../theme/duo_typography.dart';
import 'duo_button.dart';

class DuoNotificationBell extends StatefulWidget {
  final String role; // 'admin', 'bank_staff', 'donor', 'requester', 'all'
  final String? recipientId;

  const DuoNotificationBell({
    super.key,
    this.role = 'all',
    this.recipientId,
  });

  @override
  State<DuoNotificationBell> createState() => _DuoNotificationBellState();
}

class _DuoNotificationBellState extends State<DuoNotificationBell> {
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

  void _openNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DuoColors.redTint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DuoColors.redShadow, width: 1.5),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: DuoColors.red, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifications', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                          Text('$_unreadCount unread alerts', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: () async {
                        for (final n in _notifications) {
                          if (!n.isRead) {
                            await SupabaseService().markNotificationAsRead(n.id);
                          }
                        }
                        await _loadNotifications();
                        setSheetState(() {});
                      },
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          color: DuoColors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: DuoColors.border),
              const SizedBox(height: 8),

              // Notification List
              Expanded(
                child: _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_off_outlined, size: 48, color: DuoColors.textSecondary),
                            const SizedBox(height: 12),
                            Text('No announcements right now', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text('You will see live blood emergency alerts here.', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (_, index) => const Divider(height: 1, color: DuoColors.border),
                        itemBuilder: (ctx, i) {
                          final n = _notifications[i];
                          final isUnread = !n.isRead;
                          final categoryColor = _getCategoryColor(n.category);
                          final categoryIcon = _getCategoryIcon(n.category);

                          return InkWell(
                            onTap: () async {
                              if (isUnread) {
                                await SupabaseService().markNotificationAsRead(n.id);
                                await _loadNotifications();
                                setSheetState(() {});
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: categoryColor.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: categoryColor, width: 1.5),
                                    ),
                                    child: Icon(categoryIcon, size: 20, color: categoryColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                n.title,
                                                style: TextStyle(
                                                  fontFamily: DuoTypography.fontFamily,
                                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 14,
                                                  color: DuoColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (isUnread)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: DuoColors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n.body,
                                          style: DuoTypography.caption(color: DuoColors.textSecondary),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatTime(n.createdAt),
                                          style: const TextStyle(
                                            fontFamily: DuoTypography.fontFamily,
                                            fontSize: 10,
                                            color: DuoColors.textMuted,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),
              DuoButton(
                label: 'CLOSE',
                variant: DuoButtonVariant.primary,
                height: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'emergency':
        return DuoColors.red;
      case 'camp':
        return const Color(0xFF2B70C9);
      case 'milestone':
        return const Color(0xFFD4AF37);
      case 'stock':
        return DuoColors.green;
      default:
        return DuoColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'emergency':
        return Icons.emergency_rounded;
      case 'camp':
        return Icons.campaign_rounded;
      case 'milestone':
        return Icons.military_tech_rounded;
      case 'stock':
        return Icons.inventory_2_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _unreadCount;

    return GestureDetector(
      onTap: () => _openNotificationsSheet(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DuoColors.border, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: DuoColors.border,
              offset: Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_rounded,
              size: 20,
              color: DuoColors.textPrimary,
            ),
            if (unread > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: DuoColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        fontFamily: DuoTypography.fontFamily,
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
