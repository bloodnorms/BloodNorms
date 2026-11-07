// ============================================================================
// BloodNorms | hospitals_registry_view.dart
// Verified Hospitals & Clinical Facilities Directory View
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: hospitalsList.map((h) => ListTile(
              leading: const Icon(Icons.local_hospital_rounded, color: BrandColors.red),
              title: Text(
                h['name'] ?? 'Hospital',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                '${h['city']} · Phone: ${h['contact_phone'] ?? h['emergency_phone']} · Blood Bank: ${h['blood_bank_attached'] == true ? "YES" : "NO"}',
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrandColors.greenTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'VERIFIED',
                  style: TextStyle(
                    color: BrandColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            )).toList(),
      ),
    );
  }
}
