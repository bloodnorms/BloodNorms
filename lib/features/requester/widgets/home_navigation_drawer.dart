// ============================================================================
// BloodNorms | home_navigation_drawer.dart
// Bottom Sheet Navigation Menu & Localization Language Picker Modal
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';
import 'home_nav_tile.dart';
import 'language_picker_sheet.dart';

export 'home_nav_tile.dart';
export 'language_picker_sheet.dart';

class HomeNavigationDrawer extends StatelessWidget {
  const HomeNavigationDrawer({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const HomeNavigationDrawer(),
    );
  }

  static void showLanguageModal(
    BuildContext context, {
    required ValueChanged<Locale> onLocaleChanged,
  }) =>
      showLanguagePickerModal(context, onLocaleChanged: onLocaleChanged);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BloodNorms Navigation',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 10),
            const Text(
              'SERVICES',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const HomeNavTile(
              icon: Icons.water_drop_rounded,
              title: 'Request Blood',
              subtitle: 'Emergency multi-wave search',
              route: '/group',
            ),
            const HomeNavTile(
              icon: Icons.favorite_rounded,
              title: 'Become a Donor',
              subtitle: 'Register & save lives locally',
              route: '/donor',
            ),
            const HomeNavTile(
              icon: Icons.local_hospital_rounded,
              title: 'Blood Banks Directory',
              subtitle: 'Live stock & contact details',
              route: '/b',
            ),
            const HomeNavTile(
              icon: Icons.campaign_rounded,
              title: 'Donation Camps',
              subtitle: 'Upcoming local blood drives',
              route: '/donor/camps',
            ),
            const HomeNavTile(
              icon: Icons.badge_rounded,
              title: 'My Donor Pass',
              subtitle: 'View your digital donor card',
              route: '/donor/profile',
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 10),
            const Text(
              'MANAGEMENT CONSOLES',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const HomeNavTile(
              icon: Icons.business_rounded,
              title: 'Blood Bank Console',
              subtitle: 'Stock update & code confirmation',
              route: '/bank',
            ),
            const HomeNavTile(
              icon: Icons.shield_rounded,
              title: 'Super Admin Console',
              subtitle: 'Live waves, kill switch & audit trail',
              route: '/admin',
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
