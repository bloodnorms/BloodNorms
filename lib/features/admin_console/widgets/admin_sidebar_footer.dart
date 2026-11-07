// ============================================================================
// BloodNorms | admin_sidebar_footer.dart
// Modern Minimal Admin Sidebar User Profile & Action Menu Footer
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class AdminSidebarFooter extends StatelessWidget {
  final bool isSidebarCompact;
  final ValueChanged<String> onPageSelected;

  const AdminSidebarFooter({
    super.key,
    required this.isSidebarCompact,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: BrandColors.borderSubtle, width: 1.0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: BrandColors.accentTint,
            child: Text(
              'SA',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.w600,
                color: BrandColors.accent,
                fontSize: 11,
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
                    'Siva (Lead Admin)',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  Text(
                    'siva@arkiolabs.com',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      color: BrandColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: BrandColors.textSecondary,
                size: 18,
              ),
              color: BrandColors.background,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BrandColors.radiusInput),
                side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
              ),
              onSelected: (val) {
                if (val == 'settings') onPageSelected('settings_algorithm');
                if (val == 'killswitch') onPageSelected('settings_killswitch');
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                  value: 'profile',
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: BrandColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Text(
                    'Algorithm Settings',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: BrandColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'killswitch',
                  child: Text(
                    'Emergency Killswitch',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: BrandColors.statusError,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
