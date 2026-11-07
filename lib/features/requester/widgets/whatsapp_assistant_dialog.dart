// ============================================================================
// BloodNorms | whatsapp_assistant_dialog.dart
// WhatsApp deep link launcher & fallback details dialog
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/brand_typography.dart';

Future<void> launchWhatsAppAssistant(BuildContext context) async {
  final uri = Uri.parse('https://wa.me/918832471234?text=Hi');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (_) {}

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chat_rounded,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'WhatsApp Assistant',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: const Text(
          'Official WhatsApp Bot: +91 88324 71234\n\nChat with BloodNorms directly on WhatsApp to find blood in minutes or register as a donor.',
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Color(0xFF4B5563),
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Got It',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
