// ============================================================================
// BloodNorms | dpdp_registry_view.dart
// DPDP Act Right-to-be-Forgotten & Erasure Requests Desk
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Digital Personal Data Protection (DPDP) Erasure Requests',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...dpdpRequests.map((d) => ListTile(
                dense: true,
                leading: const Icon(Icons.person_off_rounded, color: BrandColors.red),
                title: Text(
                  'Right-to-be-Forgotten (#${d['id']?.toString().substring(0, 6)})',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text('Phone: ${d['phone_masked']} · Channel: ${d['request_type']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BrandColors.greenTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'PROCESSED',
                    style: TextStyle(
                      color: BrandColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
