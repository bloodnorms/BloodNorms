// ============================================================================
// BloodNorms | admin_sidebar_footer.dart
// Admin Sidebar User Profile & Action Menu Footer
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
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF22242B))),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: BrandColors.redTint,
            child: Text(
              'SA',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                color: BrandColors.red,
                fontSize: 12,
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
                    'Siva (Super Admin)',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'siva@arkiolabs.com',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: Color(0xFF9CA3AF), size: 18),
              color: const Color(0xFF1E2028),
              onSelected: (val) {
                if (val == 'settings') onPageSelected('settings_algorithm');
                if (val == 'killswitch') onPageSelected('settings_killswitch');
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                  value: 'profile',
                  child: Text('View Profile (Super Admin)',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Text('Algorithm Settings',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                PopupMenuItem(
                  value: 'killswitch',
                  child: Text('Master Killswitch',
                      style: TextStyle(
                          color: BrandColors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
