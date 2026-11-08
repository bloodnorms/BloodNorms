// ============================================================================
// BloodNorms | immediate_assistance_row.dart
// Immediate Assistance Channels: WhatsApp Assistant & Emergency Helpline Call
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'helpline_call_dialog.dart';
import 'whatsapp_assistant_dialog.dart';

export 'helpline_call_dialog.dart';
export 'whatsapp_assistant_dialog.dart';

class ImmediateAssistanceRow extends StatelessWidget {
  const ImmediateAssistanceRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // WhatsApp Channel Card
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              onTap: () => launchWhatsAppAssistant(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.background,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BrandColors.statusSuccessTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: BrandColors.statusSuccess,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Chat directly to request',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Emergency Call Card
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(BrandColors.radiusCard),
              onTap: () => showHelplineCallDialog(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.background,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BrandColors.statusErrorTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_outlined,
                        color: BrandColors.statusError,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Call Helpline',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '24/7 voice assistance',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
