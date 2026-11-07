// ============================================================================
// BloodNorms | admin_sidebar.dart
// Untitled UI Expandable Nested Sidebar Navigation (#121316 Deep Charcoal Dark)
// Modular Widget Composing Header, Navigation Tree, and User Footer
// ============================================================================

import 'package:flutter/material.dart';
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
        color: Color(0xFF121316),
        border: Border(right: BorderSide(color: Color(0xFF22242B), width: 1.5)),
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
