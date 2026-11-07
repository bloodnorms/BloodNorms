// ============================================================================
// BloodNorms | notifications_sheet.dart
// In-app notifications announcement bottom sheet
// ============================================================================

import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';
import 'action_button.dart';
import 'notification_item_tile.dart';

export 'notification_item_tile.dart';

void showNotificationsSheet(
  BuildContext context, {
  required List<InAppNotificationModel> notifications,
  required Future<void> Function() onRefresh,
  required Future<void> Function(String id) onMarkRead,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BrandColors.redTint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: BrandColors.redShadow,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: BrandColors.red,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: BrandTypography.title2(
                              color: BrandColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$unreadCount unread alerts',
                            style: BrandTypography.caption(
                              color: BrandColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: () async {
                        for (final n in notifications) {
                          if (!n.isRead) {
                            await onMarkRead(n.id);
                          }
                        }
                        await onRefresh();
                        setSheetState(() {});
                      },
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: BrandColors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: BrandColors.border),
              const SizedBox(height: 8),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: BrandColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No announcements right now',
                              style: BrandTypography.headline(
                                color: BrandColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You will see live blood emergency alerts here.',
                              style: BrandTypography.caption(
                                color: BrandColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (_, index) =>
                            const Divider(height: 1, color: BrandColors.border),
                        itemBuilder: (ctx, i) {
                          final n = notifications[i];
                          return NotificationItemTile(
                            notification: n,
                            onTap: () async {
                              if (!n.isRead) {
                                await onMarkRead(n.id);
                                await onRefresh();
                                setSheetState(() {});
                              }
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'CLOSE',
                variant: ActionButtonVariant.primary,
                height: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    ),
  );
}
