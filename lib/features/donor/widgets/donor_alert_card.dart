// ============================================================================
// BloodNorms | donor_alert_card.dart
// Interactive card displaying incoming emergency blood request with Accept / Decline
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/request_alert_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class DonorAlertCard extends StatelessWidget {
  final RequestAlertModel alert;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const DonorAlertCard({
    super.key,
    required this.alert,
    required this.isAccepting,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BrandColors.background,
          borderRadius: BorderRadius.circular(BrandColors.radiusCard),
          border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.statusErrorTint,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  ),
                  child: Text(
                    alert.urgency == 'now' ? 'URGENT NOW' : 'WITHIN 24H',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: BrandColors.statusError,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.location_on_outlined, size: 14, color: BrandColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'RAJAHMUNDRY',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: BrandColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(alert.hospitalName, style: BrandTypography.title2(color: BrandColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              '${alert.unitsNeeded} Unit ${alert.bloodGroup} ${alert.component.replaceAll('_', ' ')} needed for patient (${alert.patientFirstName})',
              style: BrandTypography.body(color: BrandColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    label: isAccepting ? 'Accepting...' : 'Accept',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: isAccepting,
                    variant: AppPillButtonVariant.primary,
                    onPressed: isAccepting ? null : onAccept,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPillButton(
                    label: 'Decline',
                    variant: AppPillButtonVariant.secondary,
                    onPressed: onDecline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
