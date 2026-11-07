// ============================================================================
// BloodNorms | speech_bubble.dart
// Conversational speech bubble component with 3D tactile borders
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: BrandColors.redTint,
            shape: BoxShape.circle,
            border: Border.all(color: BrandColors.red, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: BrandColors.border,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji ?? '🩸',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BrandColors.border, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: BrandColors.border,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              text,
              style: BrandTypography.body(color: BrandColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

/// Backward compatibility alias
typedef DuoSpeechBubble = SpeechBubble;
