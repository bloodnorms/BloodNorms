// ============================================================================
// BloodNorms | admin_sidebar.dart
// Modern Minimal Light Sidebar Navigation (#F8F9FA Soft Surface)
// Modular Widget Composing Header, Navigation Tree, and User Footer
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import 'admin_sidebar_footer.dart';
import 'admin_sidebar_header.dart';
import 'admin_sidebar_navigation_tree.dart';

export 'admin_sidebar_navigation_tree.dart';

class AdminSidebar extends StatelessWidget {
  final String activePage;
  final bool isSidebarCompact;
  final Set<String> expandedCategories;
  final ValueChanged<String> onPageSelected;
  final VoidCallback onToggleCompact;
  final ValueChanged<String> onToggleCategory;
  final bool isPermanent;

  const AdminSidebar({
    super.key,
    required this.activePage,
    required this.isSidebarCompact,
    required this.expandedCategories,
    required this.onPageSelected,
    required this.onToggleCompact,
    required this.onToggleCategory,
    required this.isPermanent,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isSidebarCompact ? 68.0 : 256.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: BrandColors.surfaceSoft,
        border: Border(
          right: BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          AdminSidebarHeader(
            isSidebarCompact: isSidebarCompact,
            onToggleCompact: onToggleCompact,
          ),
          Expanded(
            child: AdminSidebarNavigationTree(
              activePage: activePage,
              isSidebarCompact: isSidebarCompact,
              expandedCategories: expandedCategories,
              onPageSelected: onPageSelected,
              onToggleCategory: onToggleCategory,
              isPermanent: isPermanent,
            ),
          ),
          AdminSidebarFooter(
            isSidebarCompact: isSidebarCompact,
            onPageSelected: onPageSelected,
          ),
        ],
      ),
    );
  }
}
