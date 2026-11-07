// ============================================================================
// BloodNorms | safety_desk_view.dart
// Modern Minimal Clinical Safety & Adverse Donor Incidents Desk
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class SafetyDeskView extends StatelessWidget {
  final List<Map<String, dynamic>> safetyIncidents;

  const SafetyDeskView({
    super.key,
    required this.safetyIncidents,
  });

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
            'Clinical safety and incident tracking',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Adverse donor reaction monitoring and clinical escalation review',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...safetyIncidents.map((inc) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
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
                            color: BrandColors.statusWarningTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.healing_outlined,
                            size: 16,
                            color: BrandColors.statusWarning,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${inc['title']} (${inc['severity']})',
                              style: const TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: BrandColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${inc['description']} · Status: ${inc['status']}',
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
                        color: BrandColors.statusSuccessTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: const Text(
                        'Closed',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: BrandColors.statusSuccess,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
