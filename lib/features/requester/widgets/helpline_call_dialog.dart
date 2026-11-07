// ============================================================================
// BloodNorms | helpline_call_dialog.dart
// Emergency phone call dialog offering National 108 and Verified Blood Desk options
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/brand_typography.dart';

void showHelplineCallDialog(BuildContext context) {
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
              color: const Color(0xFFFEE8E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.phone_in_talk_rounded,
              color: Color(0xFFE52E2E),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Emergency Voice Call',
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
        'Select an immediate assistance channel:\n\n'
        '• 108 — National Emergency Ambulance\n'
        '• BloodNorms Helpline — 24/7 Verified Blood Desk',
        style: TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: Color(0xFF4B5563),
          height: 1.45,
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52E2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('tel:108');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: const Text(
                  'Call 108',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('tel:+918832471234');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: const Text(
                  'Desk Helpline',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
