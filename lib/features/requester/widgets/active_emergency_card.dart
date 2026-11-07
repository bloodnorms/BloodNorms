// ============================================================================
// BloodNorms | active_emergency_card.dart
// Active Emergency Search Card with Live Radar & Cancellation Controls
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_typography.dart';
import '../providers/request_flow_provider.dart';

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
          Row(
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
                    bg,
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
                      '$units ${units == 1 ? "Unit" : "Units"} $bg Needed',
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
                  onPressed: () => _showStopSearchDialog(context, id),
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

  void _showStopSearchDialog(BuildContext context, String reqId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE52E2E), width: 2.0),
        ),
        title: const Text(
          'Stop Search?',
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE52E2E),
          ),
        ),
        content: const Text(
          'This will cancel the active request in Supabase and notify contacted donors that blood is no longer needed.',
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'KEEP SEARCHING',
                    style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await SupabaseService().closeRequest(
                      reqId,
                      outcome: 'cancelled_by_requester',
                      status: 'cancelled',
                    );
                    globalRequestFlow.clearActiveRequestId();
                    onSearchStopped();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Active blood request cancelled.'),
                          backgroundColor: Color(0xFFE52E2E),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52E2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'STOP',
                    style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold),
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
