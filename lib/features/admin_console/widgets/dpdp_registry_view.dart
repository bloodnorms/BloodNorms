// ============================================================================
// BloodNorms | dpdp_registry_view.dart
// Modern Minimal DPDP Act Right-to-be-Forgotten & Erasure Requests Desk
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DPDPRegistryView extends StatelessWidget {
  final List<Map<String, dynamic>> dpdpRequests;

  const DPDPRegistryView({
    super.key,
    required this.dpdpRequests,
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
            'DPDP erasure requests',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Digital Personal Data Protection Act compliance and right-to-be-forgotten audit registry',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...dpdpRequests.map((d) => Container(
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
                            color: BrandColors.statusErrorTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_off_outlined,
                            size: 16,
                            color: BrandColors.statusError,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Right-to-be-forgotten (#${d['id']?.toString().substring(0, 6)})',
                              style: const TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: BrandColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Phone: ${d['phone_masked']} · Channel: ${d['request_type']}',
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
                        'Processed',
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
