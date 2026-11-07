// ============================================================================
// BloodNorms | approvals_queue_view.dart
// Modern Minimal Four-Eyes Governance Approvals Queue View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_pill_button.dart';

class ApprovalsQueueView extends StatelessWidget {
  final List<Map<String, dynamic>> approvalRequests;
  final void Function(String id, bool approve) onDecideApproval;

  const ApprovalsQueueView({
    super.key,
    required this.approvalRequests,
    required this.onDecideApproval,
  });

  @override
  Widget build(BuildContext context) {
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
            'Four-eyes approvals queue',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'High-impact actions requiring independent maker-checker verification',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (approvalRequests.isEmpty)
            const AppEmptyState(
              icon: Icons.verified_user_outlined,
              title: 'Queue is clear',
              description: 'Zero pending approval requests. All governed operations are up to date.',
            )
          else
            ...approvalRequests.map((a) {
              final id = a['id']?.toString() ?? '';
              final action = a['action_type'] ?? 'broadcast.mass';
              final reason = a['reason'] ?? 'Emergency mobilization';
              final maker = a['maker_id'] ?? 'admin-01';

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
                          '$action (#${id.substring(0, id.length > 8 ? 8 : id.length)})',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: BrandColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Requested by: $maker · Reason: $reason',
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
                          label: 'Approve request',
                          icon: Icons.check_circle_outline_rounded,
                          variant: AppPillButtonVariant.primary,
                          onPressed: () => onDecideApproval(id, true),
                        ),
                        const SizedBox(width: 8),
                        AppPillButton(
                          label: 'Reject',
                          variant: AppPillButtonVariant.secondary,
                          onPressed: () => onDecideApproval(id, false),
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
