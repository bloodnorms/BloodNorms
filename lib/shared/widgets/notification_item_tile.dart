// ============================================================================
// BloodNorms | notification_item_tile.dart
// Notification list item tile with category icon, status indicator, and timestamp
// ============================================================================

import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class NotificationItemTile extends StatelessWidget {
  final InAppNotificationModel notification;
  final VoidCallback onTap;

  const NotificationItemTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'emergency':
        return BrandColors.red;
      case 'camp':
        return const Color(0xFF2B70C9);
      case 'milestone':
        return const Color(0xFFD4AF37);
      case 'stock':
        return BrandColors.green;
      default:
        return BrandColors.textSecondary;
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
    final isUnread = !notification.isRead;
    final categoryColor = _getCategoryColor(notification.category);
    final categoryIcon = _getCategoryIcon(notification.category);

    return InkWell(
      onTap: onTap,
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
                          notification.title,
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                            color: BrandColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: BrandColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: BrandTypography.caption(
                      color: BrandColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 10,
                      color: BrandColors.textMuted,
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
  }
}
