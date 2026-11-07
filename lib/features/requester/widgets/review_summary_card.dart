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
          style: BrandTypography.caption(color: BrandColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: BrandColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, color: BrandColors.border),
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
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrandColors.redTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BrandColors.redShadow, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_rounded, size: 20, color: BrandColors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  safetyNoticeText,
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
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

