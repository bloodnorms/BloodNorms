// ============================================================================
// BloodNorms | bank_camp_card.dart
// Interactive Camp Metric & Action Card for Blood Bank Console
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

class BankCampCard extends StatelessWidget {
  final CampModel camp;
  final VoidCallback onCheckIn;
  final VoidCallback onRoster;
  final VoidCallback onBroadcast;

  const BankCampCard({
    super.key,
    required this.camp,
    required this.onCheckIn,
    required this.onRoster,
    required this.onBroadcast,
  });

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${camp.startsAt.day} ${_monthName(camp.startsAt.month)} ${camp.startsAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  camp.title,
                  style: BrandTypography.headline(color: BrandColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.redTint,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: BrandColors.redShadow, width: 1.0),
                ),
                child: Text(
                  camp.status.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: BrandColors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: BrandColors.red),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${camp.venue}, ${camp.area} (${camp.city})',
                  style: BrandTypography.body(color: BrandColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$dateStr · Target: ${camp.capacity} units',
                style: BrandTypography.caption(color: BrandColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: BrandColors.bgGrouped,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Radius: ${camp.targetRadiusKm.toInt()} km',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 10,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: camp.attendeesCheckedIn > 0
                      ? BrandColors.greenTint
                      : BrandColors.bgGrouped,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: camp.attendeesCheckedIn > 0
                        ? BrandColors.greenShadow
                        : BrandColors.border,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.how_to_reg_rounded,
                      size: 14,
                      color: camp.attendeesCheckedIn > 0
                          ? BrandColors.green
                          : BrandColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${camp.attendeesCheckedIn} Checked In',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: camp.attendeesCheckedIn > 0
                            ? BrandColors.green
                            : BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.redTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BrandColors.redShadow, width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bloodtype_rounded, size: 14, color: BrandColors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${camp.unitsCollected} Units',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ActionButton(
                  label: 'CHECK-IN',
                  icon: Icons.qr_code_scanner_rounded,
                  variant: ActionButtonVariant.success,
                  height: 40,
                  onPressed: onCheckIn,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 3,
                child: ActionButton(
                  label: 'ROSTER',
                  icon: Icons.people_outline_rounded,
                  variant: ActionButtonVariant.secondary,
                  height: 40,
                  onPressed: onRoster,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 3,
                child: ActionButton(
                  label: 'BROADCAST',
                  icon: Icons.campaign_rounded,
                  variant: ActionButtonVariant.primary,
                  height: 40,
                  onPressed: onBroadcast,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
