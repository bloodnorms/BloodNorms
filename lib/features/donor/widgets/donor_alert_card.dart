// ============================================================================
// BloodNorms | donor_alert_card.dart
// Interactive card displaying incoming emergency blood request with Accept / Decline
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/request_alert_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

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
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BrandColors.redShadow, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: BrandColors.redShadow,
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
          ],
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
                    color: BrandColors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert.urgency == 'now' ? 'URGENT NOW' : 'WITHIN 24H',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.redTint,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: BrandColors.redShadow, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: BrandColors.red),
                      SizedBox(width: 4),
                      Text(
                        'RAJAHMUNDRY',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: BrandColors.red,
                          fontWeight: FontWeight.bold,
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
              style: BrandTypography.body(color: BrandColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: isAccepting ? 'ACCEPTING...' : 'ACCEPT',
                    icon: Icons.check_circle_rounded,
                    variant: ActionButtonVariant.success,
                    height: 48,
                    onPressed: isAccepting ? null : onAccept,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    label: 'DECLINE',
                    variant: ActionButtonVariant.secondary,
                    height: 48,
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
