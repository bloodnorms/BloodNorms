// ============================================================================
// BloodNorms | active_emergency_card.dart
// Active Emergency Search Card with Live Radar & Cancellation Controls
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_typography.dart';
import '../providers/request_flow_provider.dart';
import 'emergency_blood_group_header.dart';
import 'stop_search_dialog.dart';

class ActiveEmergencyCard extends StatelessWidget {
  final Map<String, dynamic> activeRequest;
  final VoidCallback onSearchStopped;

  const ActiveEmergencyCard({
    super.key,
    required this.activeRequest,
    required this.onSearchStopped,
  });

  @override
  Widget build(BuildContext context) {
    final bg = activeRequest['blood_group']?.toString() ?? 'Blood';
    final units = (activeRequest['units_needed'] as num?)?.toInt() ?? 1;
    final hospital = activeRequest['hospital_name']?.toString() ?? 'Hospital';
    final contacted = (activeRequest['donors_contacted'] as num?)?.toInt() ?? 0;
    final agreed = (activeRequest['donors_accepted'] as num?)?.toInt() ?? 0;
    final ring = (activeRequest['current_ring_km'] as num?)?.toDouble() ?? 1.0;
    final id = activeRequest['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE52E2E), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE5E7EB),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE52E2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ACTIVE SEARCH IN PROGRESS',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE52E2E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE52E2E), width: 1.2),
                ),
                child: Text(
                  'RING: ${ring.toStringAsFixed(1)} KM',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE52E2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EmergencyBloodGroupHeader(
            bloodGroup: bg,
            units: units,
            hospital: hospital,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Contacted: $contacted',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const Text('•', style: TextStyle(color: Color(0xFFD1D5DB))),
                Text(
                  'Agreed: $agreed',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/live/$id'),
                  icon: const Icon(Icons.radar_rounded, size: 18),
                  label: const Text(
                    'VIEW LIVE MAP',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52E2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => showStopEmergencySearchDialog(
                    context: context,
                    reqId: id,
                    onSearchStopped: onSearchStopped,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE52E2E),
                    side: const BorderSide(color: Color(0xFFE52E2E), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'STOP',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
