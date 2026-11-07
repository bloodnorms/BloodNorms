// ============================================================================
// BloodNorms | approvals_queue_view.dart
// Four-Eyes Governance Approvals Queue View (Maker-Checker Separation)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: approvalRequests.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Zero pending Four-Eyes approval requests',
                  style: TextStyle(color: BrandColors.textSecondary),
                ),
              ),
            )
          : ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: approvalRequests.map((a) {
                final id = a['id']?.toString() ?? '';
                final action = a['action_type'] ?? 'broadcast.mass';
                final reason = a['reason'] ?? 'Emergency mobilization';
                final maker = a['maker_id'] ?? 'admin-01';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Maker: $maker · Reason: $reason',
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => onDecideApproval(id, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BrandColors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Approve (Checker)'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => onDecideApproval(id, false),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
