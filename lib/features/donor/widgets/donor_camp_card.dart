// ============================================================================
// BloodNorms | donor_camp_card.dart
// Interactive card widget displaying camp details, progress meter, and RSVP CTA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isJoined ? BrandColors.greenShadow : BrandColors.border,
          width: 2.0,
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Box
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isJoined ? BrandColors.greenTint : BrandColors.redTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isJoined ? BrandColors.greenShadow : BrandColors.redShadow,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isJoined ? BrandColors.greenShadow : BrandColors.redShadow,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      month,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        color: isJoined ? BrandColors.green : BrandColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      day,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        color: isJoined ? BrandColors.green : BrandColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: BrandColors.red),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 14, color: BrandColors.textSecondary),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrandColors.bgGrouped,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: BrandColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.near_me_rounded, size: 12, color: BrandColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~${distanceKm.toStringAsFixed(1)} KM Away',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: inTravelZone ? BrandColors.greenTint : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  inTravelZone ? '✓ In Your Zone' : 'Outside Zone',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: inTravelZone ? BrandColors.green : const Color(0xFFB45309),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onOpenDirections,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.directions_rounded, size: 14, color: BrandColors.red),
                      SizedBox(width: 3),
                      Text(
                        'Route',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Cap: ${camp.capacity}',
                style: BrandTypography.caption(color: BrandColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (count / camp.capacity).clamp(0.0, 1.0),
              backgroundColor: BrandColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isJoined ? BrandColors.green : BrandColors.red,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          ActionButton(
            label: isJoined ? 'REGISTERED ✓' : 'JOIN CAMP',
            icon: isJoined ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
            variant: isJoined ? ActionButtonVariant.success : ActionButtonVariant.primary,
            height: 44,
            onPressed: onToggleJoin,
          ),
        ],
      ),
    );
  }
}
