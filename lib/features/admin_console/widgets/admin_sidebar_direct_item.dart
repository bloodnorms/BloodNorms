// ============================================================================
// BloodNorms | admin_sidebar_direct_item.dart
// Modern Minimal Direct Navigation Item Tile for Admin Sidebar
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class AdminSidebarDirectItem extends StatelessWidget {
  final String id;
  final String title;
  final IconData icon;
  final String? badge;
  final Color? badgeColor;
  final bool isSelected;
  final bool isCompact;
  final bool isPermanent;
  final ValueChanged<String> onSelected;

  const AdminSidebarDirectItem({
    super.key,
    required this.id,
    required this.title,
    required this.icon,
    this.badge,
    this.badgeColor,
    required this.isSelected,
    required this.isCompact,
    required this.isPermanent,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Tooltip(
        message: title,
        preferBelow: false,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? BrandColors.accentTint : Colors.transparent,
            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isSelected ? BrandColors.accent : BrandColors.textSecondary,
              size: 18,
            ),
            onPressed: () {
              onSelected(id);
              if (!isPermanent) Navigator.pop(context);
            },
          ),
        ),
      );
    }

    final activeBg = isSelected ? BrandColors.accentTint : Colors.transparent;
    final itemColor = isSelected ? BrandColors.accent : BrandColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: activeBg,
        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
          onTap: () {
            onSelected(id);
            if (!isPermanent) Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Icon(icon, size: 18, color: itemColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                      color: isSelected ? BrandColors.accent : BrandColors.textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? BrandColors.accent).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeColor ?? BrandColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
