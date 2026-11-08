// ============================================================================
// BloodNorms | donor_privacy_card.dart
// Privacy & Data Rights section card (JSON data export & health quick-check indicator)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorPrivacyCard extends StatelessWidget {
  final VoidCallback onExportData;

  const DonorPrivacyCard({
    super.key,
    required this.onExportData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Privacy & Data Rights', style: BrandTypography.title3(color: BrandColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(BrandColors.radiusCard)),
                  onTap: onExportData,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: BrandColors.statusErrorTint,
                            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                          ),
                          child: const Icon(Icons.description_outlined, color: BrandColors.statusError, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Export My Data (JSON)', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Download copy of personal records (DPDP Act)', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: BrandColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: BrandColors.borderSubtle),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BrandColors.statusSuccessTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: const Icon(Icons.favorite_outline_rounded, color: BrandColors.statusSuccess, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health Quick-Check', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Verified · Due in 5 months', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
