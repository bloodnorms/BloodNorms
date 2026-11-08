// ============================================================================
// BloodNorms | review_summary_card.dart
// Summary card presenting emergency request parameters and clinical safety notice
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/blood_group_tile.dart';
import '../providers/request_flow_provider.dart';

class ReviewSummaryCard extends StatelessWidget {
  final RequestFlowState state;
  final String safetyNoticeText;

  const ReviewSummaryCard({
    super.key,
    required this.state,
    required this.safetyNoticeText,
  });

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 13,
            color: BrandColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: BrandColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (state.bloodGroup != null)
                    BloodGroupTile(
                      bloodGroup: state.bloodGroup!,
                      isSelected: false,
                      size: 64,
                      onTap: () {},
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.units} ${state.units == 1 ? "Unit" : "Units"} ${state.component.label}',
                          style: BrandTypography.title2(color: BrandColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Urgency: ${state.urgency.label.toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: BrandColors.statusError,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28, color: BrandColors.borderSubtle),
              _buildDetailRow('Hospital', state.hospitalName.isNotEmpty ? state.hospitalName : state.placeLabel),
              const SizedBox(height: 12),
              _buildDetailRow('Patient', state.patientFirstName.isNotEmpty ? state.patientFirstName : 'Not specified'),
              const SizedBox(height: 12),
              _buildDetailRow('Contact', state.requesterPhone.isNotEmpty ? state.requesterPhone : 'Not specified'),
              const SizedBox(height: 12),
              _buildDetailRow('Compatible', state.allowCompatible ? 'Allowed' : 'Exact Group Only'),
              if (state.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Note', state.note),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrandColors.statusErrorTint,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.statusError.withValues(alpha: 0.2), width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, size: 20, color: BrandColors.statusError),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  safetyNoticeText,
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 13,
                    height: 1.4,
                    color: BrandColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
