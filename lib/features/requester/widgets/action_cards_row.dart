// ============================================================================
// BloodNorms | action_cards_row.dart
// Side-by-side cards: "Become a Donor" & "Find Blood Camps"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class ActionCardsRow extends StatelessWidget {
  const ActionCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Card: Become a Donor
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final dId = prefs.getString('current_donor_id');
                if (context.mounted) {
                  if (dId != null && dId.isNotEmpty) {
                    context.push('/donor');
                  } else {
                    context.push('/donor/onboarding');
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.background,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BrandColors.statusErrorTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: const Icon(
                        Icons.favorite_outline_rounded,
                        color: BrandColors.statusError,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Become a\nDonor',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Get matched to nearby requests',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11.5,
                        color: BrandColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right Card: Find Blood Camps
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              onTap: () => context.push('/donor/camps'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.background,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BrandColors.accentTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: BrandColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Find Blood\nCamps',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upcoming drives near you',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11.5,
                        color: BrandColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
