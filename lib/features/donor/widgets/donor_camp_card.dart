// ============================================================================
// BloodNorms | donor_camp_card.dart
// Interactive card widget displaying camp details, progress meter, and RSVP CTA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'camp_date_box.dart';
import 'camp_distance_zone_row.dart';

class DonorCampCard extends StatelessWidget {
  final CampModel camp;
  final double distanceKm;
  final double donorTravelRadius;
  final bool isJoined;
  final int baseRegistered;
  final VoidCallback onToggleJoin;
  final VoidCallback onOpenDirections;

  const DonorCampCard({
    super.key,
    required this.camp,
    required this.distanceKm,
    required this.donorTravelRadius,
    required this.isJoined,
    this.baseRegistered = 35,
    required this.onToggleJoin,
    required this.onOpenDirections,
  });

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMM').format(camp.startsAt).toUpperCase();
    final day = DateFormat('dd').format(camp.startsAt);
    final time = '${DateFormat('hh:mm a').format(camp.startsAt)} – ${DateFormat('hh:mm a').format(camp.endsAt)}';
    final count = baseRegistered + (isJoined ? 1 : 0);
    final inTravelZone = distanceKm <= donorTravelRadius;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(
          color: isJoined ? BrandColors.statusSuccess.withValues(alpha: 0.4) : BrandColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Box
              CampDateBox(
                month: month,
                day: day,
                isJoined: isJoined,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camp.title,
                      style: BrandTypography.title2(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: BrandColors.statusError),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${camp.venue}, ${camp.area} (${camp.city})',
                            style: BrandTypography.caption(color: BrandColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined, size: 14, color: BrandColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: BrandTypography.caption(color: BrandColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distance and Zone Badges
          CampDistanceZoneRow(
            distanceKm: distanceKm,
            inTravelZone: inTravelZone,
            onOpenDirections: onOpenDirections,
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count donors registered',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: BrandColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                'Cap: ${camp.capacity}',
                style: BrandTypography.caption(color: BrandColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            child: LinearProgressIndicator(
              value: (count / camp.capacity).clamp(0.0, 1.0),
              backgroundColor: BrandColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(
                isJoined ? BrandColors.statusSuccess : BrandColors.primaryAction,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          AppPillButton(
            label: isJoined ? 'Registered ✓' : 'Join Camp',
            icon: isJoined ? Icons.check_circle_outline_rounded : Icons.add_circle_outline_rounded,
            variant: isJoined ? AppPillButtonVariant.tonal : AppPillButtonVariant.primary,
            isFullWidth: true,
            onPressed: onToggleJoin,
          ),
        ],
      ),
    );
  }
}
