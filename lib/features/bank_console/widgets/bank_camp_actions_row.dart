// ============================================================================
// BloodNorms | bank_camp_actions_row.dart
// Interactive action row for blood drive management: Check-in, Roster, Broadcast
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/widgets/action_button.dart';

class BankCampActionsRow extends StatelessWidget {
  final VoidCallback onCheckIn;
  final VoidCallback onRoster;
  final VoidCallback onBroadcast;

  const BankCampActionsRow({
    super.key,
    required this.onCheckIn,
    required this.onRoster,
    required this.onBroadcast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ActionButton(
            label: 'CHECK-IN',
            icon: Icons.qr_code_scanner_rounded,
            variant: ActionButtonVariant.success,
            height: 40,
            onPressed: onCheckIn,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: ActionButton(
            label: 'ROSTER',
            icon: Icons.people_outline_rounded,
            variant: ActionButtonVariant.secondary,
            height: 40,
            onPressed: onRoster,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: ActionButton(
            label: 'BROADCAST',
            icon: Icons.campaign_rounded,
            variant: ActionButtonVariant.primary,
            height: 40,
            onPressed: onBroadcast,
          ),
        ),
      ],
    );
  }
}
