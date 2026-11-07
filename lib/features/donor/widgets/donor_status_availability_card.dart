// ============================================================================
// BloodNorms | donor_status_availability_card.dart
// Donor availability toggle card and progress meters
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/progress_meter.dart';
import 'donor_pause_sheet.dart';

class DonorStatusAvailabilityCard extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggleAvailability;

  const DonorStatusAvailabilityCard({
    super.key,
    required this.isAvailable,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('donor.available'),
                    style: BrandTypography.title2(color: BrandColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable
                        ? 'Ready for emergency alerts'
                        : 'Paused in Supabase',
                    style: BrandTypography.caption(color: BrandColors.textSecondary),
                  ),
                ],
              ),
              Switch(
                value: isAvailable,
                activeThumbColor: BrandColors.green,
                onChanged: (val) {
                  if (!val) {
                    showDonorPauseSheet(
                      context,
                      onToggleAvailability: onToggleAvailability,
                    );
                  } else {
                    onToggleAvailability(true);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 2, thickness: 2, color: BrandColors.border),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  ProgressMeter(
                    value: 1.0,
                    color: BrandColors.green,
                    centerText: '✓',
                    subText: loc.t('donor.active'),
                    size: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status',
                    style: BrandTypography.caption(color: BrandColors.textSecondary),
                  ),
                ],
              ),
              Column(
                children: [
                  const ProgressMeter(
                    value: 0.8,
                    color: BrandColors.red,
                    centerText: '14',
                    subText: 'days',
                    size: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.t('donor.next'),
                    style: BrandTypography.caption(color: BrandColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
