// ============================================================================
// BloodNorms | broadcast_history_view.dart
// Regional Broadcast Campaign History View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class BroadcastHistoryView extends StatelessWidget {
  final List<Map<String, dynamic>> broadcastHistory;

  const BroadcastHistoryView({
    super.key,
    required this.broadcastHistory,
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
      child: broadcastHistory.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No broadcast history recorded yet',
                  style: TextStyle(color: BrandColors.textSecondary),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: broadcastHistory.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (ctx, i) {
                final b = broadcastHistory[i];
                return ListTile(
                  leading: const Icon(Icons.send_rounded, color: BrandColors.green),
                  title: Text(
                    b['title'] ?? 'Campaign',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    '${b['city']} · Radius: ${b['radius_km']}km · Reached: ${b['recipients_count']} donors',
                  ),
                  trailing: Text(
                    '₹${b['cost_inr']} INR',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
