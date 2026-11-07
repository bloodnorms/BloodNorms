// ============================================================================
// BloodNorms | whatsapp_chat_bubble_preview.dart
// Simulated WhatsApp Verified Green Chat Bubble Preview Widget
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class WhatsAppChatBubblePreview extends StatelessWidget {
  final String formattedMessageBody;

  const WhatsAppChatBubblePreview({
    super.key,
    required this.formattedMessageBody,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAE2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF25D366),
                child: Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 14),
              ),
              SizedBox(width: 8),
              Text(
                'BloodNorms Assistant (Verified)',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.verified_rounded, color: Color(0xFF25D366), size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFD9FDD3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedMessageBody,
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '10:42 AM',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFF6B7280)),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.done_all_rounded,
                          size: 14, color: Color(0xFF53BDEB)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
