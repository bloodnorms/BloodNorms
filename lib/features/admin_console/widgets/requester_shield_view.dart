// ============================================================================
// BloodNorms | requester_shield_view.dart
// Requester Fraud Prevention & Abuse Shield Registry View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class RequesterShieldView extends StatelessWidget {
  final List<Map<String, dynamic>> requestersList;
  final void Function(String phone, bool currentBlocked) onToggleRequesterBlock;

  const RequesterShieldView({
    super.key,
    required this.requestersList,
    required this.onToggleRequesterBlock,
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
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: requestersList.map((r) {
          final phone = r['phone'] ?? '';
          final isBlocked = r['is_blocked'] == true;
          final total = r['total_requests'] ?? 1;
          final score = r['abuse_score'] ?? r['risk_score'] ?? 0;

          return ListTile(
            leading: Icon(
              isBlocked ? Icons.block_rounded : Icons.phone_android_rounded,
              color: isBlocked ? BrandColors.red : BrandColors.green,
            ),
            title: Text(
              phone,
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: Text('$total requests · Fraud Risk: $score/100'),
            trailing: ElevatedButton(
              onPressed: () => onToggleRequesterBlock(phone, isBlocked),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? BrandColors.green : BrandColors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(isBlocked ? 'UNBLOCK' : 'BLOCK'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
