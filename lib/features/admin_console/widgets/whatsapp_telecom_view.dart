// ============================================================================
// BloodNorms | whatsapp_telecom_view.dart
// Telecom & Messaging Rate Cards View (INR Cost Ledger)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class WhatsAppTelecomView extends StatelessWidget {
  const WhatsAppTelecomView({super.key});

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
            'Itemized Telecom Rate Cards (INR)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 14),
          ListTile(
            dense: true,
            leading: Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF16A34A)),
            title: Text(
              'Meta WhatsApp Business Utility Message',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: Text('Regional Emergency Mobilization Template'),
            trailing: Text(
              '₹0.85 / msg',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.phone_in_talk_outlined, color: Color(0xFF2563EB)),
            title: Text(
              'Twilio Programmable Outbound Voice',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: Text('Voice Gateway PSTN termination to Andhra Pradesh'),
            trailing: Text(
              '₹1.20 / min',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
