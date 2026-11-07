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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BrandColors.border, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: BrandColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  onTap: onExportData,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: BrandColors.redTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BrandColors.redShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.description_rounded, color: BrandColors.red, size: 20),
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
                        const Icon(Icons.chevron_right_rounded, size: 18, color: BrandColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: BrandColors.border),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BrandColors.greenTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: BrandColors.greenShadow, width: 1.5),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: BrandColors.green, size: 20),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BrandColors.greenTint,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: BrandColors.greenShadow, width: 1.0),
                      ),
                      child: const Text('OK', style: TextStyle(color: BrandColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
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
