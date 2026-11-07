// ============================================================================
// BloodNorms | admin_sidebar_header.dart
// Modern Minimal Admin Sidebar Top Brand Header & Search Pill
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class AdminSidebarHeader extends StatelessWidget {
  final bool isSidebarCompact;
  final VoidCallback onToggleCompact;

  const AdminSidebarHeader({
    super.key,
    required this.isSidebarCompact,
    required this.onToggleCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BrandColors.primaryAction,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              if (!isSidebarCompact) ...[
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BloodNorms',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Operations console',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 11,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleCompact,
                  icon: const Icon(
                    Icons.keyboard_double_arrow_left_rounded,
                    color: BrandColors.textSecondary,
                    size: 18,
                  ),
                  tooltip: 'Collapse sidebar',
                  splashRadius: 18,
                ),
              ],
            ],
          ),
        ),
        if (!isSidebarCompact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BrandColors.background,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: BrandColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search actions...  ⌘K',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        color: BrandColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
