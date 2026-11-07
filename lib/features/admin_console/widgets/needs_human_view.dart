// ============================================================================
// BloodNorms | needs_human_view.dart
// Manual Triage Queue for Stalled Crises Requiring Human Intervention
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class NeedsHumanView extends StatelessWidget {
  final List<Map<String, dynamic>> liveRequests;
  final void Function(String id, double currentKm) onWidenRequest;
  final void Function(String id) onCloseRequest;

  const NeedsHumanView({
    super.key,
    required this.liveRequests,
    required this.onWidenRequest,
    required this.onCloseRequest,
  });

  @override
  Widget build(BuildContext context) {
    final needsHuman = liveRequests.where((r) {
      final ring = (r['current_ring_km'] as num?)?.toDouble() ?? 1.5;
      final accepted = (r['donors_accepted'] as num?)?.toInt() ?? 0;
      return ring >= 5.0 || accepted == 0;
    }).toList();

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
            'Crises Stalled or Requiring Human Intervention (>5km search ring or zero accepted)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          if (needsHuman.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Queue Clear! Zero stalled requests.',
                  style: TextStyle(color: BrandColors.textSecondary),
                ),
              ),
            )
          else
            ...needsHuman.map((r) {
              final id = r['id']?.toString() ?? '';
              final hosp = r['hospital_name'] ?? 'Hospital';
              final bg = r['blood_group'] ?? 'O+';
              final phone = r['requester_phone'] ?? '';
              final ring = (r['current_ring_km'] as num?)?.toDouble() ?? 5.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$hosp · Needs $bg',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Search Ring: ${ring.toStringAsFixed(1)}km · Requester: $phone',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => onWidenRequest(id, ring),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BrandColors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Widen to 15km'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => onCloseRequest(id),
                          child: const Text('Resolve'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
