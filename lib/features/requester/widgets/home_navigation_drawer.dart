// ============================================================================
// BloodNorms | home_navigation_drawer.dart
// Bottom Sheet Navigation Menu & Localization Language Picker Modal
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_typography.dart';

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
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Language / భాష / भाषा',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            _buildLangTile(ctx, 'English', const Locale('en'), onLocaleChanged),
            const SizedBox(height: 8),
            _buildLangTile(ctx, 'తెలుగు (Telugu)', const Locale('te'), onLocaleChanged),
            const SizedBox(height: 8),
            _buildLangTile(ctx, 'हिंदी (Hindi)', const Locale('hi'), onLocaleChanged),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLangTile(
    BuildContext ctx,
    String label,
    Locale locale,
    ValueChanged<Locale> onLocaleChanged,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        onLocaleChanged(locale);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: Color(0xFFE52E2E),
            ),
          ],
        ),
      ),
    );
  }

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
            _buildNavTile(
              context,
              icon: Icons.water_drop_rounded,
              title: 'Request Blood',
              subtitle: 'Emergency multi-wave search',
              route: '/group',
            ),
            _buildNavTile(
              context,
              icon: Icons.favorite_rounded,
              title: 'Become a Donor',
              subtitle: 'Register & save lives locally',
              route: '/donor',
            ),
            _buildNavTile(
              context,
              icon: Icons.local_hospital_rounded,
              title: 'Blood Banks Directory',
              subtitle: 'Live stock & contact details',
              route: '/b',
            ),
            _buildNavTile(
              context,
              icon: Icons.campaign_rounded,
              title: 'Donation Camps',
              subtitle: 'Upcoming local blood drives',
              route: '/donor/camps',
            ),
            _buildNavTile(
              context,
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
            _buildNavTile(
              context,
              icon: Icons.business_rounded,
              title: 'Blood Bank Console',
              subtitle: 'Stock update & code confirmation',
              route: '/bank',
            ),
            _buildNavTile(
              context,
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

  Widget _buildNavTile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.pop(ctx);
        ctx.push(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFE52E2E), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
