// ============================================================================
// BloodNorms | live_tracking_bottom_bar.dart
// Sticky bottom action bar for live tracking screen (Got blood, Stop, Return home)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/app_pill_button.dart';

class LiveTrackingBottomBar extends StatelessWidget {
  final bool isClosed;
  final String gotBloodLabel;
  final String stopLabel;
  final VoidCallback onReturnHome;
  final VoidCallback onGotBlood;
  final VoidCallback onStopSearch;

  const LiveTrackingBottomBar({
    super.key,
    required this.isClosed,
    required this.gotBloodLabel,
    required this.stopLabel,
    required this.onReturnHome,
    required this.onGotBlood,
    required this.onStopSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: BrandColors.background,
        border: Border(top: BorderSide(color: BrandColors.borderSubtle, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: isClosed
            ? AppPillButton(
                label: 'Return to Home',
                icon: Icons.home_rounded,
                variant: AppPillButtonVariant.primary,
                isFullWidth: true,
                onPressed: onReturnHome,
              )
            : Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppPillButton(
                      label: gotBloodLabel,
                      icon: Icons.check_circle_outline_rounded,
                      variant: AppPillButtonVariant.primary,
                      isFullWidth: true,
                      onPressed: onGotBlood,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: AppPillButton(
                      label: stopLabel,
                      variant: AppPillButtonVariant.secondary,
                      isFullWidth: true,
                      onPressed: onStopSearch,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
