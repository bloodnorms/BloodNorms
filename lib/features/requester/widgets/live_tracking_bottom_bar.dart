// ============================================================================
// BloodNorms | live_tracking_bottom_bar.dart
// Sticky bottom action bar for live tracking screen (Got blood, Stop, Return home)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/action_button.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.border, width: 2.0)),
      ),
      child: isClosed
          ? ActionButton(
              label: 'RETURN TO HOME',
              icon: Icons.home_rounded,
              variant: ActionButtonVariant.primary,
              onPressed: onReturnHome,
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ActionButton(
                    label: gotBloodLabel,
                    icon: Icons.check_circle_rounded,
                    variant: ActionButtonVariant.success,
                    onPressed: onGotBlood,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ActionButton(
                    label: stopLabel,
                    variant: ActionButtonVariant.secondary,
                    onPressed: onStopSearch,
                  ),
                ),
              ],
            ),
    );
  }
}
