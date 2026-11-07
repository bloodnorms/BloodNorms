// ============================================================================
// BloodNorms | admin_sidebar_direct_item.dart
// Direct Navigation Item Tile for Admin Sidebar
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
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1F222B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1F222B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            onSelected(id);
            if (!isPermanent) Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                      color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? BrandColors.red).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? BrandColors.red,
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
