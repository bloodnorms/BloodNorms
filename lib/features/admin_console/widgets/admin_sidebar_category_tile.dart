// ============================================================================
// BloodNorms | admin_sidebar_category_tile.dart
// Expandable Category Accordion Tile for Admin Sidebar
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
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: hasActiveChild ? const Color(0xFF1F222B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              categoryIcon,
              color: hasActiveChild ? Colors.white : const Color(0xFF9CA3AF),
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
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onToggleCategory(categoryId),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
            child: Row(
              children: [
                Icon(
                  categoryIcon,
                  size: 17,
                  color: hasActiveChild ? Colors.white : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    categoryTitle,
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: hasActiveChild ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                      color: hasActiveChild ? Colors.white : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? BrandColors.red).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? BrandColors.red,
                      ),
                    ),
                  ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 18),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFF282B37), width: 1.5)),
            ),
            child: Column(
              children: children.map((child) {
                final id = child['id']!;
                final title = child['title']!;
                final isSelected = activePage == id;

                return Container(
                  margin: const EdgeInsets.only(left: 8, bottom: 2, top: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1F222B) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        onPageSelected(id);
                        if (!isPermanent) Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6.5),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? BrandColors.red
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontFamily: BrandTypography.fontFamily,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 11.5,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
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
