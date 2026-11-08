// ============================================================================
// BloodNorms | bank_camp_card.dart
// Interactive Camp Metric & Action Card for Blood Bank Console
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'bank_camp_actions_row.dart';

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

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _monthName(int m) => (m >= 1 && m <= 12) ? _months[m - 1] : '';

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${camp.startsAt.day} ${_monthName(camp.startsAt.month)} ${camp.startsAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Text(
                  camp.title,
                  style: BrandTypography.title3(color: BrandColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrandColors.statusErrorTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  border: Border.all(color: BrandColors.statusError.withValues(alpha: 0.3), width: 1.0),
                ),
                child: Text(
                  camp.status.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: BrandColors.statusError,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: BrandColors.statusError),
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
                  color: BrandColors.surfaceSoft,
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
                      ? BrandColors.statusSuccessTint
                      : BrandColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  border: Border.all(
                    color: camp.attendeesCheckedIn > 0
                        ? BrandColors.statusSuccess.withValues(alpha: 0.3)
                        : BrandColors.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.how_to_reg_outlined,
                      size: 14,
                      color: camp.attendeesCheckedIn > 0
                          ? BrandColors.statusSuccess
                          : BrandColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${camp.attendeesCheckedIn} Checked In',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: camp.attendeesCheckedIn > 0
                            ? BrandColors.statusSuccess
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
                  color: BrandColors.statusErrorTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  border: Border.all(color: BrandColors.statusError.withValues(alpha: 0.3), width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_outlined, size: 14, color: BrandColors.statusError),
                    const SizedBox(width: 4),
                    Text(
                      '${camp.unitsCollected} Units',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.statusError,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BankCampActionsRow(
            onCheckIn: onCheckIn,
            onRoster: onRoster,
            onBroadcast: onBroadcast,
          ),
        ],
      ),
    );
  }
}
