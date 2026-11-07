// ============================================================================
// BloodNorms | community_partners_view.dart
// Community Partners & NGO Collaborators Registry View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class CommunityPartnersView extends StatelessWidget {
  final List<Map<String, dynamic>> partnersList;

  const CommunityPartnersView({
    super.key,
    required this.partnersList,
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
        children: partnersList.map((p) => ListTile(
              leading: const Icon(Icons.handshake_rounded, color: Color(0xFFEA580C)),
              title: Text(
                p['name'] ?? 'Partner',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                'Type: ${p['organization_type'] ?? "NGO"} · Coordinator: ${p['contact_person'] ?? "Lead"} · Camps: ${p['camps_organized_count']}',
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrandColors.greenTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'ACTIVE MOU',
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
