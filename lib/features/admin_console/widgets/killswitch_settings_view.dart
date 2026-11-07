// ============================================================================
// BloodNorms | killswitch_settings_view.dart
// Modern Minimal Master Platform Killswitch & Emergency Circuit Breaker Desk
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class KillswitchSettingsView extends StatelessWidget {
  final bool killSwitchActive;
  final void Function(bool val) onToggleKillSwitch;

  const KillswitchSettingsView({
    super.key,
    required this.killSwitchActive,
    required this.onToggleKillSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: killSwitchActive ? BrandColors.statusErrorTint : BrandColors.surfaceSoft,
          borderRadius: BorderRadius.circular(BrandColors.radiusCard),
          border: Border.all(
            color: killSwitchActive ? BrandColors.statusError : BrandColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.power_settings_new_rounded,
                        color: killSwitchActive ? BrandColors.statusError : BrandColors.textPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Master platform killswitch',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: killSwitchActive ? BrandColors.statusError : BrandColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    killSwitchActive
                        ? 'Active: All outbound calls, SMS and intake are paused in Supabase'
                        : 'Normal operations running smoothly across all pilot regions',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 12,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: killSwitchActive,
              activeColor: BrandColors.statusError,
              onChanged: onToggleKillSwitch,
            ),
          ],
        ),
      ),
    );
  }
}
