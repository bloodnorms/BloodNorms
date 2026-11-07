// ============================================================================
// BloodNorms | live_tracking_status_header.dart
// Top banner and view toggle header for live emergency search tracking
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

class LiveTrackingStatusHeader extends StatelessWidget {
  final bool isClosed;
  final String closedStatus;
  final String closedOutcome;
  final String bloodGroup;
  final String hospitalName;
  final bool showMap;
  final VoidCallback onToggleView;

  const LiveTrackingStatusHeader({
    super.key,
    required this.isClosed,
    required this.closedStatus,
    required this.closedOutcome,
    required this.bloodGroup,
    required this.hospitalName,
    required this.showMap,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isClosed)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: closedStatus == 'cancelled' ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: closedStatus == 'cancelled' ? BrandColors.red : BrandColors.green, width: 2.0),
              boxShadow: const [BoxShadow(color: BrandColors.border, offset: Offset(0, 4), blurRadius: 0)],
            ),
            child: Row(
              children: [
                Icon(
                  closedStatus == 'cancelled' ? Icons.close_rounded : Icons.check_rounded,
                  color: closedStatus == 'cancelled' ? BrandColors.red : BrandColors.green,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    closedStatus == 'cancelled'
                        ? 'This emergency request was cancelled (${closedOutcome.isNotEmpty ? closedOutcome : "by requester"}).'
                        : 'Blood request was fulfilled successfully (${closedOutcome.isNotEmpty ? closedOutcome : "completed"}).',
                    style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, color: BrandColors.textPrimary),
                  ),
                ),
              ],
            ),
          )
        else
          SpeechBubble(
            emoji: '📡',
            text: "Searching for $bloodGroup donors around $hospitalName. Contacts and responses update in real time below!",
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onToggleView,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: BrandColors.red, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(showMap ? Icons.radar_rounded : Icons.map_rounded, size: 16, color: BrandColors.red),
                    const SizedBox(width: 6),
                    Text(
                      showMap ? 'RADAR VIEW' : 'MAP VIEW',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

