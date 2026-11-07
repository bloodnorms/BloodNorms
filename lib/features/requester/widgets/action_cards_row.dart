// ============================================================================
// BloodNorms | action_cards_row.dart
// Side-by-side cards: "Become a Donor" & "Find Blood Camps"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_typography.dart';

class ActionCardsRow extends StatelessWidget {
  const ActionCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Card: Become a Donor
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/donor'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite_outline_rounded,
                      color: Color(0xFFE52E2E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Become a\nDonor',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Get matched to nearby requests',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right Card: Find Blood Camps
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/donor/camps'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFE52E2E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find Blood\nCamps',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Upcoming drives near you',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                      height: 1.3,
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
