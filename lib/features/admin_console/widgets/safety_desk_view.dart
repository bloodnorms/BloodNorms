// ============================================================================
// BloodNorms | safety_desk_view.dart
// Clinical Safety & Adverse Donor Incidents Desk
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
            'Clinical Safety & Adverse Donor Incidents Desk',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...safetyIncidents.map((inc) => ListTile(
                dense: true,
                leading: const Icon(Icons.healing_rounded, color: BrandColors.red),
                title: Text(
                  '${inc['title']} (${inc['severity']})',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text('${inc['description']} · Status: ${inc['status']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: BrandColors.greenTint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CLOSED',
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
