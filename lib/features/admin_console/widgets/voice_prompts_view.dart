// ============================================================================
// BloodNorms | voice_prompts_view.dart
// Clinical AI Voice Triage Prompts & Guardrails View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class VoicePromptsView extends StatelessWidget {
  const VoicePromptsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Prompts & Clinical Safety Guardrails',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Active Version: v2.4-godavari-clinical · Temperature: 0.30 · Native Gemini Live API',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 12,
              color: BrandColors.textSecondary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '1. Always confirm emergency blood group and unit count before initiating donor search.\n'
            '2. In Godavari Telugu, speak with natural polite phrasing ("Namaste andi, em blood group kavali?").\n'
            '3. Never give clinical diagnosis or medical treatment advice.\n'
            '4. Section 0.3 Hard Privacy: Zero audio and zero transcripts stored in database.',
          ),
        ],
      ),
    );
  }
}
