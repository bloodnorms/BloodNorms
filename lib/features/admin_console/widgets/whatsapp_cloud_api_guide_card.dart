// ============================================================================
// BloodNorms | whatsapp_cloud_api_guide_card.dart
// Meta WhatsApp Cloud API Setup & Developer Instructions Card
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class WhatsAppCloudApiGuideCard extends StatelessWidget {
  const WhatsAppCloudApiGuideCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: Color(0xFF0F172A)),
              SizedBox(width: 8),
              Text(
                'Meta WhatsApp Cloud API Instructions',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '1. Go to developers.facebook.com -> WhatsApp -> API Setup\n'
            '2. Add recipient number under sandbox phone numbers\n'
            '3. Copy 15-digit Phone Number ID and Bearer Token',
            style:
                TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }
}
