// ============================================================================
// BloodNorms | donor_home_tab_view.dart
// Donor Home Dashboard Tab View — Status Card, 3D Meters, Impact Badges
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import 'donor_impact_badges_row.dart';
import 'donor_status_availability_card.dart';

class DonorHomeTabView extends StatelessWidget {
  final String donorName;
  final String donorGroup;
  final bool isAvailable;
  final int donationsCount;
  final String? latestRequestId;
  final String latestRequestHospital;
  final String latestRequestGroup;
  final ValueChanged<bool> onToggleAvailability;
  final ValueChanged<int> onOpenTab;

  const DonorHomeTabView({
    super.key,
    required this.donorName,
    required this.donorGroup,
    required this.isAvailable,
    required this.donationsCount,
    required this.latestRequestId,
    required this.latestRequestHospital,
    required this.latestRequestGroup,
    required this.onToggleAvailability,
    required this.onOpenTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgGrouped,
      appBar: ScreenHeader(
        title: 'Donor Portal',
        showBackButton: true,
        trailing: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrandColors.redTint,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: BrandColors.redShadow, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$donationsCount',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: BrandColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            SpeechBubble(
              emoji: '🩸',
              text:
                  'Welcome back, $donorName! You are currently ${isAvailable ? "active and ready to save lives" : "paused"} in Rajahmundry.',
            ),
            const SizedBox(height: 20),
            Text(
              'Hi, $donorName',
              style: BrandTypography.title1(color: BrandColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Verified BloodNorms Donor ($donorGroup)',
              style: BrandTypography.subhead(color: BrandColors.textSecondary),
            ),
            const SizedBox(height: 20),
            DonorStatusAvailabilityCard(
              isAvailable: isAvailable,
              onToggleAvailability: onToggleAvailability,
            ),
            const SizedBox(height: 24),
            DonorImpactBadgesRow(donationsCount: donationsCount),
            const SizedBox(height: 24),
            _buildPassShortcut(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPassShortcut(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (latestRequestId != null) {
          context.push('/donor/ticket/$latestRequestId');
        } else {
          onOpenTab(1);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BrandColors.redTint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BrandColors.redShadow, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: BrandColors.redShadow,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎫', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Donation Pass',
                    style: BrandTypography.headline(color: BrandColors.red),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$latestRequestHospital · $latestRequestGroup Whole blood',
                    style: BrandTypography.caption(color: BrandColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: BrandColors.red,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
