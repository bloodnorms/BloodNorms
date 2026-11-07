// ============================================================================
// BloodNorms | needs_human_view.dart
// Modern Minimal Manual Triage Queue for Stalled Crises
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_pill_button.dart';

class NeedsHumanView extends StatelessWidget {
  final List<Map<String, dynamic>> liveRequests;
  final void Function(String id, double currentKm) onWidenRequest;
  final void Function(String id) onCloseRequest;

  const NeedsHumanView({
    super.key,
    required this.liveRequests,
    required this.onWidenRequest,
    required this.onCloseRequest,
  });

  @override
  Widget build(BuildContext context) {
    final needsHuman = liveRequests.where((r) {
      final ring = (r['current_ring_km'] as num?)?.toDouble() ?? 1.5;
      final accepted = (r['donors_accepted'] as num?)?.toInt() ?? 0;
      return ring >= 5.0 || accepted == 0;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Triage queue',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Requests requiring intervention (>5 km ring or zero responses)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (needsHuman.isEmpty)
            const AppEmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'Queue is clear',
              description: 'Zero stalled requests. All emergency cases are progressing normally.',
            )
          else
            ...needsHuman.map((r) {
              final id = r['id']?.toString() ?? '';
              final hosp = r['hospital_name'] ?? 'Hospital';
              final bg = r['blood_group'] ?? 'O+';
              final phone = r['requester_phone'] ?? '';
              final ring = (r['current_ring_km'] as num?)?.toDouble() ?? 5.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$hosp · Needs $bg',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: BrandColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Search ring: ${ring.toStringAsFixed(1)} km · $phone',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 12,
                            color: BrandColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AppPillButton(
                          label: 'Widen to 15 km',
                          variant: AppPillButtonVariant.primary,
                          onPressed: () => onWidenRequest(id, ring),
                        ),
                        const SizedBox(width: 8),
                        AppPillButton(
                          label: 'Resolve',
                          variant: AppPillButtonVariant.secondary,
                          onPressed: () => onCloseRequest(id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
