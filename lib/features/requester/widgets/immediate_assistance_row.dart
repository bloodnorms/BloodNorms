// ============================================================================
// BloodNorms | immediate_assistance_row.dart
// Immediate Assistance Channels: WhatsApp Assistant & Emergency Helpline Call
// ============================================================================

import 'package:flutter/material.dart';
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
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => launchWhatsAppAssistant(context),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chat_rounded,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'WhatsApp',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Chat directly to request',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Emergency Call Card
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => showHelplineCallDialog(context),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Call Helpline',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '24/7 voice assistance',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
