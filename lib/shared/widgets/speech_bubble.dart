// ============================================================================
// BloodNorms | speech_bubble.dart
// Clean, modern contextual prompt and helper card
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final String? emoji;

  const SpeechBubble({
    super.key,
    required this.text,
    this.emoji = '🩸',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
            ),
            child: Center(
              child: Text(
                emoji ?? '🩸',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: BrandTypography.body(color: BrandColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility alias
typedef DuoSpeechBubble = SpeechBubble;
