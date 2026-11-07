// ============================================================================
// BloodNorms | directory_registry_view.dart
// Directory Registry (Hospitals, Requester Shield, Community Partners)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DirectoryRegistryView extends StatelessWidget {
  final String subPage; // 'hospitals_list' | 'requester_shield' | 'community_partners'
  final List<Map<String, dynamic>> hospitalsList;
  final List<Map<String, dynamic>> requestersList;
  final List<Map<String, dynamic>> partnersList;
  final void Function(String phone, bool currentBlocked) onToggleRequesterBlock;

  const DirectoryRegistryView({
    super.key,
    required this.subPage,
    required this.hospitalsList,
    required this.requestersList,
    required this.partnersList,
    required this.onToggleRequesterBlock,
  });

  @override
  Widget build(BuildContext context) {
    switch (subPage) {
      case 'requester_shield':
        return _buildRequesterShieldPage();
      case 'community_partners':
        return _buildCommunityPartnersPage();
      case 'hospitals_list':
      default:
        return _buildHospitalsListPage();
    }
  }

  Widget _buildHospitalsListPage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: hospitalsList.map((h) => ListTile(
              leading: const Icon(Icons.local_hospital_rounded, color: BrandColors.red),
              title: Text(h['name'] ?? 'Hospital', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${h['city']} · Phone: ${h['contact_phone'] ?? h['emergency_phone']} · Blood Bank: ${h['blood_bank_attached'] == true ? "YES" : "NO"}'),
              trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: BrandColors.greenTint, borderRadius: BorderRadius.circular(999)), child: const Text('VERIFIED', style: TextStyle(color: BrandColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
            )).toList(),
      ),
    );
  }

  Widget _buildRequesterShieldPage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: requestersList.map((r) {
          final phone = r['phone'] ?? '';
          final isBlocked = r['is_blocked'] == true;
          final total = r['total_requests'] ?? 1;
          final score = r['abuse_score'] ?? r['risk_score'] ?? 0;

          return ListTile(
            leading: Icon(isBlocked ? Icons.block_rounded : Icons.phone_android_rounded, color: isBlocked ? BrandColors.red : BrandColors.green),
            title: Text(phone, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('$total requests · Fraud Risk: $score/100'),
            trailing: ElevatedButton(
              onPressed: () => onToggleRequesterBlock(phone, isBlocked),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? BrandColors.green : BrandColors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(isBlocked ? 'UNBLOCK' : 'BLOCK'),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommunityPartnersPage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: partnersList.map((p) => ListTile(
              leading: const Icon(Icons.handshake_rounded, color: Color(0xFFEA580C)),
              title: Text(p['name'] ?? 'Partner', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Type: ${p['organization_type'] ?? "NGO"} · Coordinator: ${p['contact_person'] ?? "Lead"} · Camps: ${p['camps_organized_count']}'),
              trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: BrandColors.greenTint, borderRadius: BorderRadius.circular(999)), child: const Text('ACTIVE MOU', style: TextStyle(color: BrandColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
            )).toList(),
      ),
    );
  }
}
