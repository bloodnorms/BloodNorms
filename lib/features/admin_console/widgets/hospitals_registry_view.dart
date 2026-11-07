// ============================================================================
// BloodNorms | hospitals_registry_view.dart
// Modern Minimal Verified Hospitals & Clinical Facilities Directory View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class HospitalsRegistryView extends StatelessWidget {
  final List<Map<String, dynamic>> hospitalsList;

  const HospitalsRegistryView({
    super.key,
    required this.hospitalsList,
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
            'Verified hospital directory',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...hospitalsList.map((h) => Container(
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
                            color: BrandColors.accentTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_hospital_outlined,
                            size: 16,
                            color: BrandColors.accent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h['name'] ?? 'Hospital',
                              style: const TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: BrandColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${h['city']} · Phone: ${h['contact_phone'] ?? h['emergency_phone']} · Blood Bank: ${h['blood_bank_attached'] == true ? "Yes" : "No"}',
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
                        'Verified',
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
