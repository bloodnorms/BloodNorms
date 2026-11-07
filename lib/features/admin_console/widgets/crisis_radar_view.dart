// ============================================================================
// BloodNorms | crisis_radar_view.dart
// Modern Minimal Live Crisis Radar Listing with Ring Widening & Resolution
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';

class CrisisRadarView extends StatelessWidget {
  final List<Map<String, dynamic>> liveRequests;
  final void Function(String id, double currentKm) onWidenRequest;
  final void Function(String id) onCloseRequest;

  const CrisisRadarView({
    super.key,
    required this.liveRequests,
    required this.onWidenRequest,
    required this.onCloseRequest,
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
      child: liveRequests.isEmpty
          ? const AppEmptyState(
              icon: Icons.radar_rounded,
              title: 'No active crises on radar',
              description: 'All emergency requests have been resolved or are currently standing by.',
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: liveRequests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _buildEmergencyRow(liveRequests[i]),
            ),
    );
  }

  Widget _buildEmergencyRow(Map<String, dynamic> req) {
    final id = req['id']?.toString() ?? '';
    final hosp = req['hospital_name'] ?? 'Hospital';
    final bg = req['blood_group'] ?? 'O+';
    final units = req['units_needed'] ?? 1;
    final phone = req['requester_phone'] ?? '';
    final ringKm = (req['current_ring_km'] as num?)?.toDouble() ?? 1.5;

    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: BrandColors.statusErrorTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                ),
                child: Text(
                  bg,
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.statusError,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$hosp · $units Units',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Search ring: ${ringKm.toStringAsFixed(1)} km · $phone',
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
          Row(
            children: [
              if (phone.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.phone_outlined, size: 18, color: BrandColors.statusSuccess),
                  tooltip: 'Call requester',
                  onPressed: () async {
                    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.zoom_out_map_rounded, size: 18, color: BrandColors.accent),
                tooltip: 'Widen search (+2 km)',
                onPressed: () => onWidenRequest(id, ringKm),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: BrandColors.statusSuccess),
                tooltip: 'Resolve crisis',
                onPressed: () => onCloseRequest(id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
