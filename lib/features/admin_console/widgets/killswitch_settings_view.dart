// ============================================================================
// BloodNorms | killswitch_settings_view.dart
// Master Platform Killswitch & Emergency Circuit Breaker Desk
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: killSwitchActive ? BrandColors.redTint : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: killSwitchActive ? BrandColors.red : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.power_settings_new_rounded,
                          color: BrandColors.red, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'MASTER PLATFORM KILL SWITCH',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.red,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    killSwitchActive
                        ? 'ACTIVE: Outbound calls and intake are paused in Supabase'
                        : 'Normal operations running smoothly on ixrborkhofxlxbedpang',
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
              activeThumbColor: BrandColors.red,
              onChanged: onToggleKillSwitch,
            ),
          ],
        ),
      ),
    );
  }
}
