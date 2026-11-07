// ============================================================================
// BloodNorms | whatsapp_telecom_view.dart
// Modern Minimal Telecom & Messaging Rate Cards View (INR Cost Ledger)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class WhatsAppTelecomView extends StatelessWidget {
  const WhatsAppTelecomView({super.key});

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
          const Text(
            'Itemized telecom rate cards',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Standard network rates charged per delivered message and call minute in INR',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRateRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Meta WhatsApp Business Utility Message',
            subtitle: 'Regional emergency mobilization template',
            rate: '₹0.85 / msg',
          ),
          const SizedBox(height: 10),
          _buildRateRow(
            icon: Icons.phone_in_talk_outlined,
            title: 'Twilio Programmable Outbound Voice',
            subtitle: 'Voice gateway PSTN termination to Andhra Pradesh',
            rate: '₹1.20 / min',
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String rate,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: BrandColors.accentTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: BrandColors.accent),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 12,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrandColors.background,
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
            ),
            child: Text(
              rate,
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: BrandColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
