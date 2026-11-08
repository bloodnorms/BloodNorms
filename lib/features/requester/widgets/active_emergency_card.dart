// ============================================================================
// BloodNorms | active_emergency_card.dart
// Clean, minimal active emergency search card with live tracking CTA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'emergency_blood_group_header.dart';
import 'stop_search_dialog.dart';

class ActiveEmergencyCard extends StatelessWidget {
  final Map<String, dynamic> activeRequest;
  final VoidCallback onSearchStopped;

  const ActiveEmergencyCard({
    super.key,
    required this.activeRequest,
    required this.onSearchStopped,
  });

  @override
  Widget build(BuildContext context) {
    final bg = activeRequest['blood_group']?.toString() ?? 'Blood';
    final units = (activeRequest['units_needed'] as num?)?.toInt() ?? 1;
    final hospital = activeRequest['hospital_name']?.toString() ?? 'Hospital';
    final contacted = (activeRequest['donors_contacted'] as num?)?.toInt() ?? 0;
    final agreed = (activeRequest['donors_accepted'] as num?)?.toInt() ?? 0;
    final ring = (activeRequest['current_ring_km'] as num?)?.toDouble() ?? 1.0;
    final id = activeRequest['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.statusError.withValues(alpha: 0.3), width: 1.0),
        boxShadow: BrandColors.shadowCardHover,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: BrandColors.statusError,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Search in Progress',
                    style: BrandTypography.label(color: BrandColors.statusError),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.statusErrorTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                ),
                child: Text(
                  'Radius: ${ring.toStringAsFixed(1)} km',
                  style: BrandTypography.caption(color: BrandColors.statusError)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          EmergencyBloodGroupHeader(
            bloodGroup: bg,
            units: units,
            hospital: hospital,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: BrandColors.surfaceSoft,
              borderRadius: BorderRadius.circular(BrandColors.radiusInput),
              border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Contacted: $contacted',
                  style: BrandTypography.label(color: BrandColors.textSecondary),
                ),
                Text(
                  '•',
                  style: TextStyle(color: BrandColors.borderStrong),
                ),
                Text(
                  'Agreed: $agreed',
                  style: BrandTypography.label(color: BrandColors.statusSuccess),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppPillButton(
                  label: 'View Live Map',
                  icon: Icons.radar_rounded,
                  variant: AppPillButtonVariant.primary,
                  onPressed: () => context.push('/live/$id'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: AppPillButton(
                  label: 'Stop',
                  variant: AppPillButtonVariant.destructive,
                  onPressed: () => showStopEmergencySearchDialog(
                    context: context,
                    reqId: id,
                    onSearchStopped: onSearchStopped,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
