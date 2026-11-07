// ============================================================================
// BloodNorms | broadcast_history_view.dart
// Modern Minimal Regional Broadcast Campaign History View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';

class BroadcastHistoryView extends StatelessWidget {
  final List<Map<String, dynamic>> broadcastHistory;

  const BroadcastHistoryView({
    super.key,
    required this.broadcastHistory,
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
      child: broadcastHistory.isEmpty
          ? const AppEmptyState(
              icon: Icons.history_rounded,
              title: 'No broadcast history recorded',
              description: 'Past campaign dispatches and delivery reports will appear here.',
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: broadcastHistory.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final b = broadcastHistory[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: BrandColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: BrandColors.statusSuccessTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              size: 16,
                              color: BrandColors.statusSuccess,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b['title'] ?? 'Campaign',
                                style: const TextStyle(
                                  fontFamily: BrandTypography.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: BrandColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${b['city']} · ${b['radius_km']} km radius · ${b['recipients_count']} reached',
                                style: const TextStyle(
                                  fontFamily: BrandTypography.fontFamily,
                                  fontSize: 12,
                                  color: BrandColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BrandColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                        ),
                        child: Text(
                          '₹${b['cost_inr']} INR',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight: FontWeight.w600,
                            color: BrandColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
