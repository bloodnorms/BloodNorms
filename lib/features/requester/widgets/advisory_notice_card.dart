// ============================================================================
// BloodNorms | advisory_notice_card.dart
// Voluntary & Free Healthcare Advisory Notice + The BloodNorms Pledge Dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class AdvisoryNoticeCard extends StatelessWidget {
  const AdvisoryNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showTrustModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFE52E2E),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'BloodNorms is ',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF374151),
                      ),
                    ),
                    TextSpan(
                      text: '100% voluntary & free',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    TextSpan(
                      text: '. Never pay any agent.',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showTrustModal(BuildContext context) {
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
                Icons.verified_user_rounded,
                color: Color(0xFFE52E2E),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'The BloodNorms Pledge',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• 100% Free & Voluntary: Blood donation in India is governed by the Drugs and Cosmetics Act. Selling or buying blood is illegal.\n\n'
              '• Verified Honest Stock: Blood banks report honest units directly.\n\n'
              '• Contact Shielding: Your number is shared only when a donor accepts your emergency request.',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE52E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'I Understand',
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
