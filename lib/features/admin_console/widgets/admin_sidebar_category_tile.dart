// ============================================================================
// BloodNorms | admin_sidebar_category_tile.dart
// Modern Minimal Expandable Category Accordion Tile for Admin Sidebar
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class AdminSidebarCategoryTile extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;
  final IconData categoryIcon;
  final String? badge;
  final Color? badgeColor;
  final List<Map<String, String>> children;
  final String activePage;
  final bool isExpanded;
  final bool isCompact;
  final bool isPermanent;
  final ValueChanged<String> onToggleCategory;
  final ValueChanged<String> onPageSelected;

  const AdminSidebarCategoryTile({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryIcon,
    this.badge,
    this.badgeColor,
    required this.children,
    required this.activePage,
    required this.isExpanded,
    required this.isCompact,
    required this.isPermanent,
    required this.onToggleCategory,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveChild = children.any((c) => c['id'] == activePage);

    if (isCompact) {
      return Tooltip(
        message: categoryTitle,
        preferBelow: false,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            color: hasActiveChild ? BrandColors.accentTint : Colors.transparent,
            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
          ),
          child: IconButton(
            icon: Icon(
              categoryIcon,
              color: hasActiveChild ? BrandColors.accent : BrandColors.textSecondary,
              size: 18,
            ),
            onPressed: () => onToggleCategory(categoryId),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            onTap: () => onToggleCategory(categoryId),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    categoryIcon,
                    size: 18,
                    color: hasActiveChild ? BrandColors.accent : BrandColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      categoryTitle,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: hasActiveChild ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                        color: hasActiveChild ? BrandColors.accent : BrandColors.textPrimary,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: BrandColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 24, top: 2, bottom: 4),
            padding: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: BrandColors.borderSubtle, width: 1.5),
              ),
            ),
            child: Column(
              children: children.map((child) {
                final id = child['id']!;
                final title = child['title']!;
                final isSelected = activePage == id;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected ? BrandColors.accentTint : Colors.transparent,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      onTap: () {
                        onPageSelected(id);
                        if (!isPermanent) Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? BrandColors.accent
                                    : BrandColors.borderStrong,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontFamily: BrandTypography.fontFamily,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 12.5,
                                  color: isSelected
                                      ? BrandColors.accent
                                      : BrandColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
