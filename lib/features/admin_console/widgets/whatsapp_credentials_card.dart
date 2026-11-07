// ============================================================================
// BloodNorms | whatsapp_credentials_card.dart
// WhatsApp Meta Cloud API Credentials Configuration Card
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/messaging_service.dart';
import '../../../shared/theme/brand_typography.dart';

class WhatsAppCredentialsCard extends StatelessWidget {
  final TextEditingController phoneIdController;
  final TextEditingController accessTokenController;
  final bool is10DigitMobile;
  final VoidCallback onApplied;

  const WhatsAppCredentialsCard({
    super.key,
    required this.phoneIdController,
    required this.accessTokenController,
    required this.is10DigitMobile,
    required this.onApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.vpn_key_rounded, size: 18, color: Color(0xFF25D366)),
              SizedBox(width: 8),
              Text(
                'Meta WhatsApp Cloud API Credentials',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Values configured in assets/.env or overridden live below for rapid testing:',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          if (is10DigitMobile)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Notice: Phone Number ID is 15-to-16 digits from developers.facebook.com > WhatsApp > API Setup, NOT your personal mobile number.',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phoneIdController,
                  decoration: InputDecoration(
                    labelText: 'Meta Phone Number ID (15 digits)',
                    hintText: 'e.g. 105493829104829',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: accessTokenController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Meta Access Token (Bearer)',
                    hintText: 'EAAB...',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                WhatsAppService().setRuntimeCredentials(
                  phoneNumberId: phoneIdController.text,
                  accessToken: accessTokenController.text,
                );
                onApplied();
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Apply Credentials'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
