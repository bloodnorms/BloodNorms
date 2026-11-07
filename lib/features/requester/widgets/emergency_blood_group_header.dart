// ============================================================================
// BloodNorms | emergency_blood_group_header.dart
// Blood group circular badge with required units and hospital display
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class EmergencyBloodGroupHeader extends StatelessWidget {
  final String bloodGroup;
  final int units;
  final String hospital;

  const EmergencyBloodGroupHeader({
    super.key,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE52E2E), width: 2),
          ),
          child: Center(
            child: Text(
              bloodGroup,
              style: const TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE52E2E),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$units ${units == 1 ? "Unit" : "Units"} $bloodGroup Needed',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hospital,
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
