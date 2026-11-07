// ============================================================================
// BloodNorms | voice_prompts_view.dart
// Modern Minimal Clinical AI Voice Triage Prompts & Guardrails View
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
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prompts and clinical guardrails',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'System instructions and medical triage constraints for voice agent',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.accentTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                ),
                child: const Text(
                  'v2.4-godavari · Temp 0.30',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BrandColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BrandColors.surfaceSoft,
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Always confirm emergency blood group and unit count before initiating donor search.',
                  style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, color: BrandColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  '2. In Godavari Telugu, speak with natural polite phrasing ("Namaste andi, em blood group kavali?").',
                  style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, color: BrandColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  '3. Never give clinical diagnosis or medical treatment advice.',
                  style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, color: BrandColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  '4. Hard Privacy Line: Zero audio frames and zero speech transcripts stored in database.',
                  style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, color: BrandColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
