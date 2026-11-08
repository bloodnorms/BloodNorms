// ============================================================================
// BloodNorms | live_tracking_status_header.dart
// Top banner and view toggle header for live emergency search tracking
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/speech_bubble.dart';

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: closedStatus == 'cancelled'
                  ? BrandColors.statusErrorTint
                  : BrandColors.statusSuccessTint,
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              border: Border.all(
                color: closedStatus == 'cancelled'
                    ? BrandColors.statusError.withValues(alpha: 0.25)
                    : BrandColors.statusSuccess.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  closedStatus == 'cancelled' ? Icons.close_rounded : Icons.check_circle_outline_rounded,
                  color: closedStatus == 'cancelled' ? BrandColors.statusError : BrandColors.statusSuccess,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    closedStatus == 'cancelled'
                        ? 'This emergency request was cancelled (${closedOutcome.isNotEmpty ? closedOutcome : "by requester"}).'
                        : 'Blood request was fulfilled successfully (${closedOutcome.isNotEmpty ? closedOutcome : "completed"}).',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SpeechBubble(
            emoji: '📡',
            text: "Searching for $bloodGroup donors around $hospitalName. Contacts and responses update in real time below.",
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                onTap: onToggleView,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: BrandColors.background,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        showMap ? Icons.radar_rounded : Icons.map_rounded,
                        size: 16,
                        color: BrandColors.primaryAction,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        showMap ? 'Radar View' : 'Map View',
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
