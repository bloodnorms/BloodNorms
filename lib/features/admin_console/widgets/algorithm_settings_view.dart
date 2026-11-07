// ============================================================================
// BloodNorms | algorithm_settings_view.dart
// Search Algorithm & Ring Expansion Rules Desk (BR-06..BR-08)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class AlgorithmSettingsView extends StatelessWidget {
  const AlgorithmSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Algorithm Parameters (BR-06..BR-08)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '• Wave 1 Initial Radius: 1.5 km (3 nearby verified donors)\n'
            '• Wave 2 Expansion: +2.0 km (Total 3.5 km)\n'
            '• Wave 3 Expansion: +2.0 km (Total 5.5 km)\n'
            '• Max Geofence Cap: 15.0 km\n'
            '• Gates: Telephony gates enforced at 70km, 90km, 100km per BR-07.\n'
            '• Donor Cooldown Period: 90 days between donations.',
          ),
        ],
      ),
    );
  }
}
